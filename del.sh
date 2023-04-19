#!/bin/bash

###############################################################################
# -*- encoding: UTF-8 -*-                                                     #
# Author: Jesse C. Chen  (jessekelighine@gmail.com)                           #
# Description: `del`, a better and safer way to remove files.                 #
# Last Modified: 2023-04-16                                                   #
#                                                                             #
# License: GPL-3                                                              #
# Copyright 2022-2023 Jesse C. Chen                                           #
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

[[   -z "$DEL_DIR" ]] && DEL_DIR="$HOME/.del"
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
        -d --directory    show trash directory
        -h --history      show the last deletion
        -l --list         list all deleted files
        -r --remove       permanently remove all deleted files
        -u --undo         undo the last deletion
EOF
	exit 0
}

### Flags #####################################################################

[[ $# -eq 1 && "$1" =~ ^-{1,2}[a-zA-Z]+$ ]] && {
	case "$1" in
		-d | --directory)
			echo "$DEL_DIR"
			;;
		-l | --list)
			$DEL_LST "$DEL_DIR"
			;;
		-r | --remove)
			read -r -p "permanently remove deleted files [Yn]: "
			[[ "$REPLY" =~ [yY] ]] && \rm -rf "${DEL_DIR:?}/"*
			;;
		-h | --history)
			[[ ! -s "$DEL_HST" || ! -f "$DEL_HST" ]] && {
				_errors "no undo history available"
				exit 1
			}
			awk 'BEGIN { FS="\t" } { print $2 }' "$DEL_HST"
			;;
		-u | --undo)
			[[ ! -s "$DEL_HST" || ! -f "$DEL_HST" ]] && {
				_errors "no undo history available."
				exit 1
			}
			cat "$DEL_HST" | xargs -n 2 mv
			true > "$DEL_HST"
			;;
		*)
			_errors "unrecognized flag."
			exit 1
			;;
	esac
	exit 1
}

### Main ######################################################################

true > "$DEL_HST"
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
