#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Euxo pipefail # no -e as we may try to remove non-existent .old file

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

if [ "$#" -ne 1 ]; then
    echo "Usage: ./uninstall.sh {{kernel_version}}"
fi

KERNVER="$1"

echo "You are about to remove kernel: $KERNVER"

read -p "Are you sure? " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

if [ ! -f "/boot/initrd.img-$KERNVER" ]; then
    echo "$KERNVER does not exist."
	exit 1
fi

sudo rm "/boot/config-$KERNVER"
sudo rm "/boot/config-$KERNVER.old"
sudo rm "/boot/initrd.img-$KERNVER"
sudo rm "/boot/initrd.img-$KERNVER.old"
sudo rm "/boot/System.map-$KERNVER"
sudo rm "/boot/System.map-$KERNVER.old"
sudo rm "/boot/vmlinuz-$KERNVER"
sudo rm "/boot/vmlinuz-$KERNVER.old"
sudo rm -rf "/lib/modules/$KERNVER/"

sudo update-grub

echo "Kernel ($KERNVER) uninstalled, please reboot"
