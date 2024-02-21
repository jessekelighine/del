#!/bin/bash

###############################################################################
# -*- encoding: UTF-8 -*-                                                     #
# Author: Jesse C. Chen  (jessekelighine.com)                                 #
# Description: `del`, a better and safer way to remove files.                 #
# Last Modified: 2024-02-14                                                   #
#                                                                             #
# License: GPL-3                                                              #
# Copyright 2022-2024 Jesse C. Chen                                           #
###############################################################################

set -e

### Functions #################################################################

_errors () {
	echo "del: error: $*" >&2
}

_quotes () {
	local qq="'\\''"; echo "'${1//\'/$qq}'"
}

_redump () {
	local file; file=$( basename "$1" )
	local dirn; dirn=$( dirname  "$1" )
	local body; body="${file%%.*}"
	local extn; extn="${file#$body}"
	if [[ ! -z "$body" ]]; then
		redump="$dirn/$body-$2$extn"
	else
		_redump "${extn:1}" "$2"
		redump="$dirn/.$(basename "$redump")"
	fi
}

### Environmental Variables ###################################################

[[   -z "$DEL_DIR" ]] && DEL_DIR="$HOME/.Trash"
[[   -z "$DEL_HST" ]] && DEL_HST="$DEL_DIR/.del_history"
[[   -z "$DEL_LST" ]] && DEL_LST="find"
[[ ! -d "$DEL_DIR" ]] && {
	_errors "trash directory '$DEL_DIR' not readable."
	exit 1
}

### Help ######################################################################

[[ $# -lt 1 ]] && {
	cat << EOF
usage: del [options] [file ...]
options:
        -a --append       append deletion to history
        -d --directory    show trash directory
        -h --history      show the last deletion
        -l --list         list all deleted files
	-r --remove       show the command to rm all deleted files
        -u --undo         undo the last deletion
EOF
	exit 0
}

### Flags #####################################################################

append_hist=false
positional_args=()

while [[ $# -gt 0 ]]
do
	case "$1" in
		-a | --append)
			append_hist=true
			shift
			;;
		-d | --directory)
			echo "$DEL_DIR"
			exit 0
			;;
		-l | --list)
			$DEL_LST "$DEL_DIR"
			exit 0
			;;
		-r | --remove)
			printf "$(basename $0): rm -rf %s/*\n" "$DEL_DIR"
			exit 0
			;;
		-h | --history)
			[[ ! -s "$DEL_HST" || ! -f "$DEL_HST" ]] && {
				_errors "no undo history available"
				exit 1
			}
			awk 'BEGIN { FS="\t" } { print $2 }' "$DEL_HST"
			exit 0
			;;
		-u | --undo)
			[[ ! -s "$DEL_HST" || ! -f "$DEL_HST" ]] && {
				_errors "no undo history available."
				exit 1
			}
			cat "$DEL_HST" | xargs -n 2 mv
			true > "$DEL_HST"
			exit 0
			;;
		-* | --*)
			_errors "unknown option $1."
			exit 1
			;;
		*)
			positional_args+=("$1")
			shift
			;;
	esac
done

set -- "${positional_args[@]}"

### Main ######################################################################

[[ $append_hist != true ]] && true > "$DEL_HST"
for file in "$@"; do
	[[ ! -f "$file" && ! -d "$file" ]] && {
		_errors "file/directory \`$file\` not regular."
		exit 1
	}
	orig=$(realpath "$file")
	dump="$DEL_DIR/$(basename "$file")"
	[[ -d "$dump" || -f "$dump" ]] && {
		_redump "$dump" "$(date +'%Y%m%d%H%M%S')"
		count=0
		dump="$redump"
		while [[ -d "$redump" || -f "$redump" ]] ; do
			_redump "$dump" "$((++count))"
		done
		dump="$redump"
	}
	mv "$orig" "$dump"
	echo "$(_quotes "$dump")	$(_quotes "$orig")" >> "$DEL_HST"
done

exit 0
