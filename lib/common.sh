#!/usr/bin/env bash

# failure message
function __error_handing {
	local last_status_code=$1;
	local error_line_number=$2;
	echo 1>&2 "Error - exited with status $last_status_code at line $error_line_number";
	perl -slne 'if($.+5 >= $ln && $.-4 <= $ln){ $_="$. $_"; s/$ln/">" x length($ln)/eg; s/^\D+.*?$/\e[1;31m$&\e[0m/g;  print}' -- -ln=$error_line_number $0
}

trap '__error_handing $? $LINENO' ERR

function hook_at {
	HOOK_NAME="$1"
}

function run_script {
	_target=$(realpath -e "$1")

	if [ -f "$_target" ] && [ -x "$_target" ]; then
		echo "Running hook: $_target"
		"$_target"
	fi
}

function run_pre_hooks_slient {
	if [ -f "pre-$HOOK_NAME.sh" ]; then
		_target_list=("pre-$HOOK_NAME.sh")
	fi

	_target_list+=($(ls "pre-$HOOK_NAME."*".sh" 2>/dev/null || true))

	for _target_path in "${_target_list[@]}"; do
		run_script "$_target_path"
	done
}

function run_post_hooks_slient {
	_target_list=($(ls "post-$HOOK_NAME."*".sh" 2>/dev/null || true))

	if [ -f "post-$HOOK_NAME.sh" ]; then
		_target_list+=("post-$HOOK_NAME.sh")
	fi

	for _target_path in "${_target_list[@]}"; do
		run_script "$_target_path"
	done
}


function run_pre_hooks {
	set +x

	run_pre_hooks_slient

	set -x
}

function run_post_hooks {
	set +x

	run_post_hooks_slient

	set -x
}
