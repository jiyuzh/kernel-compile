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
NUMCPUS=$(distcc -j)

# compile kernel (using all cores)
time nice make -j"$NUMCPUS" CC="distcc"
time nice make -j"$NUMCPUS" CC="distcc" modules

# compile perf
cd tools/perf
time nice make -j"$NUMCPUS" --load-average="$NUMCPUS"
cd ../..

# hook vscode
if [ -f ./scripts/clang-tools/gen_compile_commands.py ]; then
	python3 ./scripts/clang-tools/gen_compile_commands.py
else
	"$SCRIPT_DIR/gen_compile_commands.py"
fi

run_post_hooks

# success message
KERNELRELEASE=$(cat include/config/kernel.release 2> /dev/null)
echo "Kernel ($KERNELRELEASE) compile ready, please install"
