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

# compile module (using all cores)
time nice make -j"$NUMCPUS" --load-average="$NUMCPUS"

# hook vscode
KDIR=$(make -f "$SCRIPT_DIR/lib/printvars.mak" -f Makefile print-KDIR)

if [ -f "$KDIR/scripts/clang-tools/gen_compile_commands.py" ]; then
	# works since 5.10
	make -C "$KDIR" M="$PWD" compile_commands.json
else
	MDIR=$(realpath -e "$PWD")
	pushd "$KDIR"
	python3 "$SCRIPT_DIR/lib/gen_compile_commands.py" -o "$MDIR/compile_commands.json" "$MDIR/modules.order"
	popd
fi

run_post_hooks

# success message
echo "Module compile ready, please install"
