#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

# file locator
SCRIPT_DIR=$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")

source "$SCRIPT_DIR/lib/common.sh"
hook_at "install"

run_pre_hooks

module=$(ls -t ./*.ko | head -n 1)

if [ -n "$module" ]; then
	if [ -f "$module" ]; then
		sudo insmod "$module"
	fi
fi

run_post_hooks

# success message
echo "Module ($module) install ready"
