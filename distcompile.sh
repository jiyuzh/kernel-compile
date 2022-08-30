#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

# failure message
function __error_handing {
	local last_status_code=$1;
	local error_line_number=$2;
	echo 1>&2 "Error - exited with status $last_status_code at line $error_line_number";
	perl -slne 'if($.+5 >= $ln && $.-4 <= $ln){ $_="$. $_"; s/$ln/">" x length($ln)/eg; s/^\D+.*?$/\e[1;31m$&\e[0m/g;  print}' -- -ln=$error_line_number $0
}

trap '__error_handing $? $LINENO' ERR

# get core count
NUMCPUS=`distcc -j`

# compile and install (using all cores)
time nice make -j$NUMCPUS CC="distcc"
time nice make -j$NUMCPUS CC="distcc" modules
sudo make modules_install
sudo make install
sudo update-grub

# success message
KERNELRELEASE=$(cat include/config/kernel.release 2> /dev/null)
echo "Kernel ($KERNELRELEASE) install ready, please reboot"

