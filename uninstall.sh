#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Euo pipefail # no -e as we may try to remove non-existent .old file

# file locator
SCRIPT_DIR=$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")

source "$SCRIPT_DIR/lib/common.sh"

if [ "$#" -lt 1 ]; then
	echo "Usage: ./uninstall.sh {{kernel_version}}"
	echo

	echo "Kernels installed:"
	"$SCRIPT_DIR/where.sh"
	exit 1
fi

KERNVER="$1"

KERNPKG="$(dpkg -S "/boot/vmlinuz-$KERNVER" 2> /dev/null | perl -pe 's/: .*//' || true)"
if [ -n "$KERNPKG" ]; then
	echo "Kernel $KERNVER belongs to package '$KERNPKG'."
	echo "Please remove it with your package manager."
	exit 1
fi

echo "You are about to remove kernel: $KERNVER"

read -p "Are you sure? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
	exit 1
fi

if [ ! -f "/boot/vmlinuz-$KERNVER" ]; then
	echo "$KERNVER does not exist."
	exit 1
fi

echo
echo "Uninstalling kernel $KERNVER"

sudo rm "/boot/config-$KERNVER"
sudo rm "/boot/initrd.img-$KERNVER"
sudo rm "/boot/System.map-$KERNVER"
sudo rm "/boot/vmlinuz-$KERNVER"
sudo rm "/var/lib/initramfs-tools/$KERNVER"

sudo rm -rf "/lib/modules/$KERNVER/"
sudo rm -rf "/usr/lib/linux-tools/$KERNVER/"

sudo rm "/boot/config-$KERNVER.old"
sudo rm "/boot/initrd.img-$KERNVER.old"
sudo rm "/boot/System.map-$KERNVER.old"
sudo rm "/boot/vmlinuz-$KERNVER.old"
sudo rm "/var/lib/initramfs-tools/$KERNVER.old"

read -p "Do you need to update grub? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	sudo update-grub
fi

echo "Kernel ($KERNVER) uninstalled, please reboot"
