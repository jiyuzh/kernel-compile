#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuo pipefail

# file locator
SCRIPT_DIR=$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")

source "$SCRIPT_DIR/lib/common.sh"

existing=( $(ls /boot | perl -ne 'print "$1\n" if /^vmlinuz-(.*)(?<!\.old)$/') )

for dir in /lib/modules/*; do
	installed=0

	for i in "${existing[@]}"; do
		if [[ "$i" == "$(basename "$dir")" ]]; then
			installed=1
		fi
	done

	dir=$(realpath -e "$dir")

	if [ "$installed" -eq 0 ]; then
		echo "WARNING: Orphaned module directory $dir"
	fi

	if [ -L "$dir/build" ]; then
		ls -alhF --color "$dir/build"
	elif [ -L "$dir/source" ]; then
		ls -alhF --color "$dir/source"
	else
		echo "ERROR: Unable to find compile source from $dir"
	fi
done
