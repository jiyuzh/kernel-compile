#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

# file locator
SCRIPT_DIR=$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")

source "$SCRIPT_DIR/lib/common.sh"
hook_at "install"

run_pre_hooks

# install kernel
sudo make modules_install
sudo make install
sudo update-grub

run_post_hooks

# success message
KERNELRELEASE=$(cat include/config/kernel.release 2> /dev/null)
echo "Kernel ($KERNELRELEASE) install ready, please reboot"
