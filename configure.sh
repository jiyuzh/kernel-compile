#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

# user config
CONFIG_SRC='ubuntu-5.15.config' # URL or relative to script dir
CONF_OUTPUT=".config" # in $PWD
CONF_NEWDEF=".config.newdef" # in $PWD
LSMOD_OVERRIDE="lsmod.override" # in $PWD
LOCAL_CONFIGURE="local-configure.sh" # in $PWD

# file locator
SCRIPT_DIR=$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")

source "$SCRIPT_DIR/lib/common.sh"
hook_at "config"

# help message
if [ "$#" -lt 1 ]; then
	echo "./configure.sh {{localver_name}} [{{config_template}}] [{{config_type}}] {{ext_args}}"
	echo "Automatic kernel configuration generator for Linux 5.x"
	echo "    localver_name: Value provided to CONFIG_LOCALVERSION, without leading dash"
	echo "    config_template: The template file to use with this script"
	echo "    config_type: The fullness of the config, the default value is 'lite'"
	echo "        full: Do not remove unused modules"
	echo "        lite: Remove modules that are not loaded"
	echo "    ext_args: A series of arguments tweaking the extension options"
	echo "              The default is to use all available extensions"
	echo "        --no-{1}: Exclude extension {1}"
	echo "        --with-{1}: Include extension {1}"
	exit 1
fi

# get localver name
LOCALVER="-$1"
shift

# get config base
if [ "$#" -gt 0 ]; then
	CONFIG_SRC="$1"
	shift
fi

# get full module type
CONFIGTYP="lite"
if [ "$#" -gt 0 ] && [[ "$1" == "full" ]]; then
	CONFIGTYP="full"
	shift
elif [ "$#" -gt 0 ] && [[ "$1" == "lite" ]]; then
	CONFIGTYP="lite"
	shift
elif [ "$#" -gt 0 ]; then
	echo "Unknown config mode $1"
	exit 1
fi

# generate extension list
EXT_ARGS=( "$@" "--with-local" )
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

run_pre_hooks

# backup config
if [ -f "$CONF_OUTPUT" ]; then
	TS=$(date +%s)
	mv "$CONF_OUTPUT" "$CONF_OUTPUT.$TS.bak"
fi

# obtain base config
if [[ "$CONFIG_SRC" =~ ^https?: ]]; then
	BASE_CONFIG=$(sudo mktemp "/tmp/config-template.XXXXXXXX")
	sudo wget -O "$BASE_CONFIG" "$CONFIG_SRC"
	sudo chown "$USER:$USER" "$BASE_CONFIG"
elif [ -f "$CONFIG_SRC" ]; then
	BASE_CONFIG=$(realpath -e "$CONFIG_SRC")
elif [ -f "$SCRIPT_DIR/config/$CONFIG_SRC" ]; then
	BASE_CONFIG=$(realpath -e "$SCRIPT_DIR/config/$CONFIG_SRC")
else
	echo "Unable to find config template $CONFIG_SRC"
	exit 1
fi

if ! grep -q "CONFIG_CC_IS_GCC=" "$BASE_CONFIG"; then
	echo "$CONFIG_SRC is not a valid kernel config file"
	exit 1
fi

sudo cp -f "$BASE_CONFIG" "$CONF_OUTPUT"

# localize config
make listnewconfig > "$CONF_NEWDEF"
make olddefconfig
if [[ "$CONFIGTYP" == "lite" ]]; then
	if [ -f "$LSMOD_OVERRIDE" ]; then
		echo "Detected and loaded lsmod override file: $LSMOD_OVERRIDE"
		make LSMOD="$LSMOD_OVERRIDE" localmodconfig
	else
		echo "No override file found, using live lsmod output"
		make localmodconfig
	fi
fi
echo '+' > .scmversion

# compile or install blocker
set_flag_str LOCALVERSION "$LOCALVER"
set_flag_str SYSTEM_TRUSTED_KEYS ""
set_flag_str SYSTEM_REVOCATION_KEYS ""
set_flag_num FRAME_WARN 0
enable_flags DEBUG_INFO
disable_flags DEBUG_INFO_REDUCED
enable_flags WERROR

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

run_post_hooks

set +x

"$SCRIPT_DIR/validate.sh" "nofail" "${EXT_ARGS[@]}"

echo "Kernel config is ready"
echo "Reminder: You may still need to enable custom configs before compile"

