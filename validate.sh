#!/usr/bin/env bash
set -Eeuo pipefail

# user config
LOCAL_VALIDATE="local-validate.sh" # in $PWD

# file locator
SCRIPT_DIR=$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")

source "$SCRIPT_DIR/lib/common.sh"
hook_at "validate"

# below are from https://github.com/moby/moby/blob/2deec80/contrib/check-config.sh

EXITCODE=0

CONFIG=".config"
MAKEFILE="Makefile"
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
printf '    %s\n' "${USE_EXTENSION[@]}"
echo

if ! command -v zgrep > /dev/null 2>&1; then
	zgrep() {
		zcat "$2" | grep "$1"
	}
fi

is_set() {
	zgrep "CONFIG_$1=[y|m]" "$CONFIG" > /dev/null
}
is_set_in_kernel() {
	zgrep "CONFIG_$1=y" "$CONFIG" > /dev/null
}
is_set_as_module() {
	zgrep "CONFIG_$1=m" "$CONFIG" > /dev/null
}
is_num_eq() {
	FOUND_VAL=$(perl -ne 'print $1 if /^'"CONFIG_$1"'=(.*)$/' < "$CONFIG")
	zgrep "CONFIG_$1=$2" "$CONFIG" > /dev/null
}
is_str() {
	FOUND_VAL=$(perl -ne 'print $1 if /^'"CONFIG_$1"'="(.*)"$/' < "$CONFIG")
	zgrep "CONFIG_$1=\"$2\"" "$CONFIG" > /dev/null
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
	printf -- '- '
	echo "$(wrap_color "$1" white): $(wrap_color "$2" green)"
}
wrap_bad() {
	printf -- '- '
	echo "$(wrap_color "$1" bold): $(wrap_color "$2" bold red)"
}
wrap_pass() {
	printf -- '- '
	echo "$(wrap_color "$1" white): $(wrap_color "$2" bold blue)"
}
wrap_skip() {
	printf -- '- '
	echo "$(wrap_color "$1" bold): $(wrap_color "skipped" bold yellow)"
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
		check_no_flag "$flag"
	done
}

check_num_eq() {
	if is_num_eq "$1" "$2"; then
		wrap_good "CONFIG_$1" "$FOUND_VAL"
	else
		wrap_bad "CONFIG_$1" "$FOUND_VAL"
		EXITCODE=1
	fi
}

check_str() {
	if is_str "$1" "$2"; then
		wrap_good "CONFIG_$1" "\"$FOUND_VAL\""
	else
		wrap_bad "CONFIG_$1" "\"$FOUND_VAL\""
		EXITCODE=1
	fi
}

check_arch() {
	local expect="$1"
	local actual

	actual=$(uname -m)

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

skip_flag() {
	wrap_skip "$1"
}

kern_ver_ge() {
	if [ "$KERNEL_MAJOR" -lt "$1" ]; then
		false
	elif [ "$#" -ge 2 ] && [ "$KERNEL_MINOR" -lt "$2" ]; then
		false
	elif [ "$#" -ge 3 ] && [ "$KERNEL_PATCH" -lt "$3" ]; then
		false
	elif [ "$#" -ge 4 ] && [[ "$KERNEL_EXTRA" == "-rc"* ]] && [[ "$4" == "-rc"* ]] && [[ "$KERNEL_EXTRA" < "$4" ]]; then
		false
	else
		true
	fi
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
		FAILED=$(( FAILED + 1 ))
		FAILED_EXT+=( "$name" )
	else
		SUCCED=$(( SUCCED + 1 ))
		SUCCED_EXT+=( "$name" )
	fi
}

run_pre_hooks_slient

CONFIG=$(realpath "$CONFIG")
MAKEFILE=$(realpath "$MAKEFILE")

if [ ! -e "$CONFIG" ]; then
	wrap_warning "error: cannot find kernel config"
	wrap_warning "  try running this script again, specifying the kernel config:"
	wrap_warning "    CONFIG=/path/to/kernel/.config $0 or $0 /path/to/kernel/.config"
	exit 1
fi

if [ ! -e "$MAKEFILE" ]; then
	wrap_warning "error: cannot find kernel makefile"
	wrap_warning "  try running this script again, specifying the kernel config paired with the make file:"
	wrap_warning "    CONFIG=/path/to/kernel/.config $0 or $0 /path/to/kernel/.config"
	exit 1
fi

wrap_color "info: reading kernel config from $CONFIG ..." blue
echo

KERNEL_MAJOR=$(perl -ne 'if (/^VERSION\s*=\s*(\d+)\s*(?:#.*)?$/) { print $1; $found ||= 1; } }{ print 0 if !$found' < "$MAKEFILE")
KERNEL_MINOR=$(perl -ne 'if (/^PATCHLEVEL\s*=\s*(\d+)\s*(?:#.*)?$/) { print $1; $found ||= 1; } }{ print 0 if !$found' < "$MAKEFILE")
KERNEL_PATCH=$(perl -ne 'if (/^SUBLEVEL\s*=\s*(\d+)\s*(?:#.*)?$/) { print $1; $found ||= 1; } }{ print 0 if !$found' < "$MAKEFILE")
KERNEL_EXTRA=$(perl -ne 'if (/^EXTRAVERSION\s*=\s*(.*?)\s*(?:#.*)?$/) { print $1; }' < "$MAKEFILE")

wrap_color "info: kernel version is $KERNEL_MAJOR.$KERNEL_MINOR.$KERNEL_PATCH$KERNEL_EXTRA" blue
echo

for ext in "${USE_EXTENSION[@]}"
do
	run_validate "$ext" "$SCRIPT_DIR/extension/$ext-validate.sh"
done

if [ -f "$LOCAL_VALIDATE" ]; then
	run_validate "local" "$LOCAL_VALIDATE"
fi

run_post_hooks_slient

TOTAL=$(( SUCCED + FAILED ))
echo "Validation Report:"
echo
echo "Total $TOTAL / Succeed $SUCCED / Failed $FAILED"
echo
echo "Succeed:"
printf '    %s\n' "${SUCCED_EXT[@]}"
echo
echo "Failed:"
printf '    %s\n' "${FAILED_EXT[@]}"

if [ "$SUPRESS_ERRNO" = true ]; then
	exit 0
fi

exit $FAILED
