#!/bin/bash

###############################################################################
# -*- encoding: UTF-8 -*-                                                     #
# Author: Jesse C. Chen  (jessekelighine@gmail.com)                           #
# Description: `del`, a better and safer way to remove files.                 #
# Last Modified: 2022-Dec-17                                                  #
#                                                                             #
# License: GPL-3                                                              #
# Copyright 2022 Jesse C. Chen                                                #
#                                                                             #
# This program is free software: you can redistribute it and/or modify it     #
# under the terms of the GNU General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# This program is distributed in the hope that it will be useful, but         #
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY  #
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License     #
# for more details.                                                           #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with this program. If not, see <https://www.gnu.org/licenses/>.             #
#                                                                             #
###############################################################################

set -e

[[   -z "$DEL_DIR" ]] && DEL_DIR="$HOME/.del"
[[   -z "$DEL_HST" ]] && DEL_HST="$DEL_DIR/.del_history"
[[   -z "$DEL_LST" ]] && DEL_LST="find"
[[ ! -d "$DEL_DIR" ]] && {
	echo "error: trash directory '$DEL_DIR' not readable."
	exit 1
}

### Help ######################################################################

[[ $# -lt 1 ]] && {
	cat << EOF
usage: del [-dhlru] [file ...]
flags:
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
			echo "$DEL_DIR" ;;
		-h | --history)
			awk 'BEGIN { FS="\t" } { print $2 }' "$DEL_HST" ;;
		-l | --list)
			$DEL_LST "$DEL_DIR" ;;
		-r | --remove)
			read -r -p "--> permanently remove deleted files [Yn]: "
			[[ "$REPLY" =~ [yY] ]] && /bin/rm -rf "${DEL_DIR:?}/"* ;;
		-u | --undo)
			if [[ ! -s "$DEL_HST" || ! -f "$DEL_HST" ]]; then
				echo "error: no undo history available."
				exit 1
			fi
			cat "$DEL_HST" | xargs -n 2 mv
			true > "$DEL_HST" ;;
		*)
			echo "del: unrecognized flag."
			exit 1 ;;
	esac
	exit 0
}

### Main ######################################################################

true > "$DEL_HST"
for file in "$@"; do
	[[ ! -f "$file" && ! -d "$file" ]] && {
		echo "error: file/directory '$file' not regular."
		exit 1
	}
	orig="$(realpath "$file")"
	dump="$DEL_DIR/$(basename "$file")"
	[[ -d "$dump" || -f "$dump" ]] && {
		rename="$dump-${count:=1}"
		while [[ -d "$rename" || -f "$rename" ]]; do
			count=$(( count + 1 ))
			rename="$dump-$count"
		done
		mv "$dump" "$rename"
	}
	mv "$orig" "$dump"
	echo "$dump	$orig" >> "${DEL_HST}"
done
exit 0
