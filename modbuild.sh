#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

# file locator
SCRIPT_DIR=$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")

source "$SCRIPT_DIR/lib/common.sh"
hook_at "build"

run_pre_hooks

# get core count
NUMCPUS=`grep -c '^processor' /proc/cpuinfo`

# compile module (using all cores)
time nice make -j$NUMCPUS --load-average=$NUMCPUS

# hook vscode
python3 "$SCRIPT_DIR/lib/gen_compile_commands.py"

run_post_hooks

# success message
echo "Module compile ready, please install"
