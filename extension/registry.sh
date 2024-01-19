#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -lt 2 ]; then
	echo "./registry.sh {{ext_dir}} {{ext_type}} {{ext_args}}"
	echo "Extension listing script"
	echo "    ext_dir: Directory of extension scripts"
	echo "    ext_type: Type of extension scripts"
	echo "    ext_args: A series of arguments tweaking the extension options"
	echo "              The default result is all available extensions"
	echo "        --no-{1}: Exclude extension {1}"
	echo "        --with-{1}: Include extension {1}"
	echo "        --no-all: Exclude all extensions"
	echo "        --with-all: Include all extension"
	exit 1
fi

cd "$1"
shift

TYPE="$1"
shift

HAS_EXTENSION=( $(ls *-$TYPE.sh | perl -pe "s/-$TYPE\.sh\$//") )
USE_EXTENSION=( "${HAS_EXTENSION[@]}" )

function sort_extension {
	USE_EXTENSION=( $(echo "${USE_EXTENSION[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ') )
}

function remove_extension {
	local removed="$1"
	local temp=()

	for i in "${USE_EXTENSION[@]}"
	do
		if [ "$i" != "$removed" ] ; then
			temp+=( "$i" )
		fi
	done

	USE_EXTENSION=( "${temp[@]}" )
}

function add_extension {
	local newval="$1"
	
	for i in "${HAS_EXTENSION[@]}"
	do
		if [ "$i" == "$newval" ] ; then
			USE_EXTENSION+=( "$newval" )
		fi
	done
}

function handle_default {
	for i in "${HAS_EXTENSION[@]}"
	do
		local file_content

		file_content=$( cat "$i-$TYPE.sh" )

		if [[ " $file_content " =~ $(echo '#\s*ext-default-enabled\s*:\s*no') ]]; then
			remove_extension "$i"
		fi
	done
}

function handle_arg {
	local args=( "$@" )

	for i in "${args[@]}"
	do
		if [[ "$i" == "--no-all"  ]]; then
			USE_EXTENSION=()
		fi

		if [[ "$i" == "--with-all"  ]]; then
			USE_EXTENSION=( "${HAS_EXTENSION[@]}" )
		fi

		if [[ "$i" =~ ^--no-.*  ]]; then
			ext=$(echo "$i" | perl -pe 's/^--no-//')
			remove_extension "$ext"
		fi

		if [[ "$i" =~ ^--with-.*  ]]; then
			ext=$(echo "$i" | perl -pe 's/^--with-//')
			add_extension "$ext"
		fi
	done
}

handle_default

handle_arg "$@"

sort_extension;

echo "${USE_EXTENSION[@]}"
