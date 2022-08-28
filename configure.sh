#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

# user config
BASE_CONFIG='ubuntu-22.04-5.15.config' # URL or relative to script dir
CONF_OUTPUT=".config" # in $PWD
CONF_NEWDEF=".config.newdef" # in $PWD
LSMOD_OVERRIDE="lsmod.override" # in $PWD
LOCAL_CONFIGURE="local-configure.sh" # in $PWD

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

# help message
if [ "$#" -lt 1 ]; then
	echo "./configure.sh {{localver_name}} {{ext_args}}"
	echo "Automatic kernel configuration generator for Linux 5.x"
	echo "    localver_name: Value provided to CONFIG_LOCALVERSION, without leading dash"
	echo "    ext_args: A series of arguments tweaking the extension options"
	echo "              The default is to use all available extensions"
	echo "        --no-{1}: Exclude extension {1}"
	echo "        --with-{1}: Include extension {1}"
	exit 1
fi

# get localver name
LOCALVER="-$1"
shift

# generate extension list
EXT_ARGS=( "$@" )
USE_EXTENSION=( $("$SCRIPT_DIR/extension/registry.sh" "$SCRIPT_DIR/extension" "configure" "${EXT_ARGS[@]}") )
echo "Using configuration extensions: "
echo "    ${USE_EXTENSION[@]}"

# flag operaitons
enable_flag() {
	scripts/config --enable "CONFIG_$1"
}
disable_flag() {
	scripts/config --disable "CONFIG_$1"
}
module_flag() {
	scripts/config --module "CONFIG_$1"
}

enable_flags() {
	set +x
	for flag in "$@"; do
		enable_flag "$flag"
	done
	set -x
}
disable_flags() {
	set +x
	for flag in "$@"; do
		disable_flag "$flag"
	done
	set -x
}
module_flags() {
	set +x
	for flag in "$@"; do
		module_flag "$flag"
	done
	set -x
}

set_flag_str() {
	set +x
	scripts/config --set-str "CONFIG_$1" "$2"
	set -x
}
set_flag_num() {
	set +x
	scripts/config --set-val "CONFIG_$1" "$2"
	set -x
}

set -x

# backup config
if [ -f "$CONF_OUTPUT" ]; then
	TS=$(date +%s)
	mv "$CONF_OUTPUT" "$CONF_OUTPUT.$TS.bak"
fi

# obtain base config
if [[ "$BASE_CONFIG" =~ ^https?:  ]]; then
	# from web
	wget -O "$CONF_OUTPUT" "$BASE_CONFIG"
else
	# from local
	cp -f "$SCRIPT_DIR/$BASE_CONFIG" "$CONF_OUTPUT"
fi
perl -pi.__edit_temp -e 's/^```$//g' "$CONF_OUTPUT"
rm "$CONF_OUTPUT.__edit_temp"

# localize config
make listnewconfig > "$CONF_NEWDEF"
make olddefconfig
if [ -f "$LSMOD_OVERRIDE" ]; then
	echo "Detected and loaded lsmod override file: $LSMOD_OVERRIDE"
	make LSMOD="$LSMOD_OVERRIDE" localmodconfig
else
	echo "No override file found, using live lsmod output"
	make localmodconfig
fi
echo '+' > .scmversion

# compile or install blocker
set_flag_str LOCALVERSION "$LOCALVER"
set_flag_str SYSTEM_TRUSTED_KEYS ""
set_flag_str SYSTEM_REVOCATION_KEYS ""

# quality-of-life
disable_flags SECURITY_DMESG_RESTRICT

# apply application requirements
for ext in "${USE_EXTENSION[@]}"
do
	. "$SCRIPT_DIR/extension/$ext-configure.sh"
done

if [ -f "$LOCAL_CONFIGURE" ]; then
	. "$LOCAL_CONFIGURE"
fi

# pop the menu
# this will also fix minor config issues introduced during rewrite step
# so don't remove
make menuconfig

set +x

"$SCRIPT_DIR/validate.sh" "nofail" "${EXT_ARGS[@]}"

echo "Kernel config is ready"
echo "Reminder: You may still need to enable custom configs before compile"

