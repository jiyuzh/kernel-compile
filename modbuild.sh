#!/usr/bin/env bash
# 'use strict'
# see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

# user config
LOCAL_PRE_BUILD="./pre-build.sh" # in $PWD
LOCAL_POST_BUILD="./post-build.sh" # in $PWD

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

if [ -f "$LOCAL_PRE_BUILD" ] && [ -x "$LOCAL_PRE_BUILD" ]; then
	echo "Running $LOCAL_PRE_BUILD hook"
	"$LOCAL_PRE_BUILD"
fi

# get core count
NUMCPUS=`grep -c '^processor' /proc/cpuinfo`

# compile module (using all cores)
time nice make -j$NUMCPUS --load-average=$NUMCPUS

# hook vscode
python3 "$SCRIPT_DIR/lib/gen_compile_commands.py"

if [ -f "$LOCAL_POST_BUILD" ] && [ -x "$LOCAL_POST_BUILD" ]; then
	echo "Running $LOCAL_POST_BUILD hook"
	"$LOCAL_POST_BUILD"
fi

# success message
echo "Module compile ready, please install"
