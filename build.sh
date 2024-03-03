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
NUMCPUS=$(nproc)

# compile kernel (using all cores)
time nice make -j"$NUMCPUS" --load-average="$NUMCPUS"
time nice make modules -j"$NUMCPUS" --load-average="$NUMCPUS"

# now we can know the name of the kernel
KERNELRELEASE=$(make -s kernelrelease 2> /dev/null)
if [ -z "$KERNELRELEASE" ]; then
	KERNELRELEASE=$(cat include/config/kernel.release 2> /dev/null)
fi

# prepare gdb
time nice make scripts_gdb -j"$NUMCPUS" --load-average="$NUMCPUS"

# compile perf
cd tools/perf
time nice make -j"$NUMCPUS" --load-average="$NUMCPUS"

# install perf
sudo mkdir -p "/usr/lib/linux-tools/$KERNELRELEASE/"
sudo ln -sf "$(realpath -e perf)" "/usr/lib/linux-tools/$KERNELRELEASE/perf"
cd ../..

# hook vscode
if [ -f ./scripts/clang-tools/gen_compile_commands.py ]; then
	# works since 5.10
	make compile_commands.json
else
	python3 "$SCRIPT_DIR/lib/gen_compile_commands.py"
fi

run_post_hooks

# success message
echo "Kernel ($KERNELRELEASE) compile ready, please install"
