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

# file locator
SOURCE="${BASH_SOURCE[0]:-$0}";
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname -- "$SOURCE"; )" &> /dev/null && pwd 2> /dev/null; )";
        SOURCE="$( readlink -- "$SOURCE"; )";
        [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}"; # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname -- "$SOURCE"; )" &> /dev/null && pwd 2> /dev/null; )";

# get core count
NUMCPUS=`grep -c '^processor' /proc/cpuinfo`

# compile kernel (using all cores)
time nice make -j$NUMCPUS --load-average=$NUMCPUS
time nice make modules -j$NUMCPUS --load-average=$NUMCPUS

# compile perf
cd tools/perf
time nice make -j$NUMCPUS --load-average=$NUMCPUS
cd ../..

# hook vscode
if [ -f ./scripts/clang-tools/gen_compile_commands.py ]; then
	python ./scripts/clang-tools/gen_compile_commands.py
else
	"$SCRIPT_DIR/gen_compile_commands.py"
fi

# success message
KERNELRELEASE=$(cat include/config/kernel.release 2> /dev/null)
echo "Kernel ($KERNELRELEASE) compile ready, please install"
