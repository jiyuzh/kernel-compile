#!/usr/bin/env bash
set -Eeuo pipefail

# user config
LOCAL_VALIDATE="local-validate.sh"

# failure message
function __error_handing {
	local last_status_code=$1;
	local error_line_number=$2;
	echo 1>&2 "Error - exited with status $last_status_code at line $error_line_number";
	perl -slne 'if($.+5 >= $ln && $.-4 <= $ln){ $_="$. $_"; s/$ln/">" x length($ln)/eg; s/^\D+.*?$/\e[1;31m$&\e[0m/g;  print}' -- -ln=$error_line_number $0
}

trap '__error_handing $? $LINENO' ERR

# file locator
SOURCE="${BASH_SOURCE[0]:-$0}";
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	DIR="$( cd -P "$( dirname -- "$SOURCE"; )" &> /dev/null && pwd 2> /dev/null; )";
	SOURCE="$( readlink -- "$SOURCE"; )";
	[[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}"; # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname -- "$SOURCE"; )" &> /dev/null && pwd 2> /dev/null; )";

# below are from https://github.com/moby/moby/blob/2deec80/contrib/check-config.sh

EXITCODE=0

# bits of this were adapted from lxc-checkconfig
# see also https://github.com/lxc/lxc/blob/lxc-1.0.2/src/lxc/lxc-checkconfig.in

possibleConfigs="
	/proc/config.gz
	/boot/config-$(uname -r)
	/usr/src/linux-$(uname -r)/.config
	/usr/src/linux/.config
"

CONFIG=".config"
FAILED=0
FAILED_EXT=()
SUCCED=0
SUCCED_EXT=()

if [ "$#" -gt 0 ] && [ "$1" == "nofail" ] ; then
	SUPRESS_ERRNO=true
	shift
else
	SUPRESS_ERRNO=false
fi

# generate extension list
EXT_ARGS=( "$@" )
USE_EXTENSION=( $("$SCRIPT_DIR/extension/registry.sh" "$SCRIPT_DIR/extension" "validate" "${EXT_ARGS[@]}") )
echo "Using configuration extensions: "
echo "    ${USE_EXTENSION[@]}"

if ! command -v zgrep > /dev/null 2>&1; then
	zgrep() {
		zcat "$2" | grep "$1"
	}
fi

kernelVersion="$(uname -r)"
kernelMajor="${kernelVersion%%.*}"
kernelMinor="${kernelVersion#$kernelMajor.}"
kernelMinor="${kernelMinor%%.*}"

is_set() {
	zgrep "CONFIG_$1=[y|m]" "$CONFIG" > /dev/null
}
is_set_in_kernel() {
	zgrep "CONFIG_$1=y" "$CONFIG" > /dev/null
}
is_set_as_module() {
	zgrep "CONFIG_$1=m" "$CONFIG" > /dev/null
}

color() {
	codes=
	if [ "$1" = 'bold' ]; then
		codes='1'
		shift
	fi
	if [ "$#" -gt 0 ]; then
		code=
		case "$1" in
			# see https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
			black) code=30 ;;
			red) code=31 ;;
			green) code=32 ;;
			yellow) code=33 ;;
			blue) code=34 ;;
			magenta) code=35 ;;
			cyan) code=36 ;;
			white) code=37 ;;
		esac
		if [ "$code" ]; then
			codes="${codes:+$codes;}$code"
		fi
	fi
	printf '\033[%sm' "$codes"
}
wrap_color() {
	text="$1"
	shift
	color "$@"
	printf '%s' "$text"
	color reset
	echo
}

wrap_good() {
	echo "$(wrap_color "$1" white): $(wrap_color "$2" green)"
}
wrap_bad() {
	echo "$(wrap_color "$1" bold): $(wrap_color "$2" bold red)"
}
wrap_pass() {
	echo "$(wrap_color "$1" bold): $(wrap_color "$2" bold blue)"
}
wrap_warning() {
	wrap_color >&2 "$*" red
}

check_flag() {
	if is_set_in_kernel "$1"; then
		wrap_good "CONFIG_$1" 'enabled'
	elif is_set_as_module "$1"; then
		wrap_good "CONFIG_$1" 'enabled (as module)'
	else
		wrap_bad "CONFIG_$1" 'not enabled'
		EXITCODE=1
	fi
}

check_flags() {
	for flag in "$@"; do
		printf -- '- '
		check_flag "$flag"
	done
}

check_yes_flag() {
	if is_set_in_kernel "$1"; then
		wrap_good "CONFIG_$1" 'enabled'
	elif is_set_as_module "$1"; then
		wrap_bad "CONFIG_$1" 'enabled (as module)'
		EXITCODE=1
	else
		wrap_bad "CONFIG_$1" 'not enabled'
		EXITCODE=1
	fi
}

check_yes_flags() {
	for flag in "$@"; do
		printf -- '- '
		check_yes_flag "$flag"
	done
}

check_no_flag() {
	if is_set_in_kernel "$1"; then
		wrap_bad "CONFIG_$1" 'enabled'
		EXITCODE=1
	elif is_set_as_module "$1"; then
		wrap_bad "CONFIG_$1" 'enabled (as module)'
		EXITCODE=1
	else
		wrap_pass "CONFIG_$1" 'not enabled'
	fi
}

check_no_flags() {
	for flag in "$@"; do
		printf -- '- '
		check_no_flag "$flag"
	done
}

check_arch() {
	local expect="$1"
	local actual=$(uname -m)

	if [ "$expect" = "$actual" ]; then
		wrap_good "$expect architecture" 'yes'
	else
		wrap_bad "$expect architecture" 'no'
		EXITCODE=1
	fi
}

check_command() {
	if command -v "$1" > /dev/null 2>&1; then
		wrap_good "$1 command" 'available'
	else
		wrap_bad "$1 command" 'missing'
		EXITCODE=1
	fi
}

check_device() {
	if [ -c "$1" ]; then
		wrap_good "$1" 'present'
	else
		wrap_bad "$1" 'missing'
		EXITCODE=1
	fi
}

check_distro_userns() {
	if [ ! -e /etc/os-release ]; then
		return
	fi
	. /etc/os-release 2> /dev/null || /bin/true
	case "$ID" in
		centos | rhel)
			case "$VERSION_ID" in
				7*)
					# this is a CentOS7 or RHEL7 system
					grep -q 'user_namespace.enable=1' /proc/cmdline || {
						# no user namespace support enabled
						wrap_bad "  (RHEL7/CentOS7" "User namespaces disabled; add 'user_namespace.enable=1' to boot command line)"
						EXITCODE=1
					}
					;;
			esac
			;;
	esac
}

run_validate() {
	local name="$1"
	local path="$2"

	EXITCODE=0

	echo
	echo "----------- validate $name start -----------"

	. "$path"

	echo "EXITCODE: $EXITCODE"
	echo "------------ validate $name end ------------"
	echo

	if [ $EXITCODE -ne 0 ]; then
		FAILED=$(( $FAILED + 1 ))
		FAILED_EXT+=( "$name" )
	else
		SUCCED=$(( $SUCCED + 1 ))
		SUCCED_EXT+=( "$name" )
	fi
}

if [ ! -e "$CONFIG" ]; then
	wrap_warning "warning: $CONFIG does not exist, searching other paths for kernel config ..."
	for tryConfig in $possibleConfigs; do
		if [ -e "$tryConfig" ]; then
			CONFIG="$tryConfig"
			break
		fi
	done
	if [ ! -e "$CONFIG" ]; then
		wrap_warning "error: cannot find kernel config"
		wrap_warning "  try running this script again, specifying the kernel config:"
		wrap_warning "    CONFIG=/path/to/kernel/.config $0 or $0 /path/to/kernel/.config"
		exit 1
	fi
fi

wrap_color "info: reading kernel config from $CONFIG ..." white
echo

for ext in "${USE_EXTENSION[@]}"
do
	run_validate "$ext" "$SCRIPT_DIR/extension/$ext-validate.sh"
done

if [ -f "$LOCAL_VALIDATE" ]; then
	run_validate "local" "$LOCAL_VALIDATE"
fi

TOTAL=$(( $SUCCED + $FAILED ))
echo "Validation Report:"
echo
echo "Total $TOTAL / Succeed $SUCCED / Failed $FAILED"
echo
echo "Succeed:"
echo "    ${SUCCED_EXT[@]}"
echo
echo "Failed:"
echo "    ${FAILED_EXT[@]}"

if [ "$SUPRESS_ERRNO" = true ]; then
	exit 0
fi

exit $FAILED