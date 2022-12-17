#!/bin/bash

###############################################################################
# -*- encoding: UTF-8 -*-                                                     #
# Author: Jesse C. Chen  (jessekelighine@gmail.com)                           #
# Description: `del`, a better and safer way to remove files.                 #
# Last Modified: 2022-Dec-17                                                  #
#                                                                             #
# License: The MIT License (MIT)                                              #
#                                                                             #
# Copyright 2022 by Jesse C. Chen                                             #
#                                                                             #
# Permission is hereby granted, free of charge, to any person obtaining a     #
# copy of this software and associated documentation files (the "Software"),  #
# to deal in the Software without restriction, including without limitation   #
# the rights to use, copy, modify, merge, publish, distribute, sublicense,    #
# and/or sell copies of the Software, and to permit persons to whom the       #
# Software is furnished to do so, subject to the following conditions:        #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL     #
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
#                                                                             #
###############################################################################

[[ -z "$DEL_DIR" ]] && DEL_DIR="$HOME/.del"
[[ -z "$DEL_HST" ]] && DEL_HST="$DEL_DIR/.del_history"
[[ -z "$DEL_LST" ]] && DEL_LST="find"

[[ ! -d "$DEL_DIR" ]] && {
	echo "error: trash directory '$DEL_DIR' not readable."
	exit 1
}

### Flags #####################################################################

[[ "$1" == "--directory" || "$1" == "-d" ]] && {
	echo "$DEL_DIR"
	exit 0
}

[[ "$1" == "--history" || "$1" == "-h" ]] && {
	awk 'BEGIN { FS="\t" } { print $2 }' "$DEL_HST"
	exit 0
}

[[ "$1" == "--list" || "$1" == "-l" ]] && {
	$DEL_LST "$DEL_DIR"
	exit 0
}

[[ "$1" == "--remove" || "$1" == "-r" ]] && {
	read -r -p "--> permanently remove deleted files [Yn]: "
	if [[ "$REPLY" == "Y" ]]; then
		/bin/rm -rf "${DEL_DIR:?}/"*
		echo "removed"
	else
		echo "cancelled"
	fi
	exit 0
}

[[ "$1" == "--undo" || "$1" == "-u" ]] && {
	if [[ ! -s "$DEL_HST" || ! -f "$DEL_HST" ]]; then
		echo "error: no undo history available."
		exit 1
	fi
	cat "$DEL_HST" | xargs -n 2 mv
	true > "$DEL_HST"
	exit 0
}

### Help ######################################################################

[[ $# -lt 1 ]] && {
	echo "usage: del [-dhlru] [file ...]                                 "
	echo "flags:                                                         "
	echo "        -d --directory    show trash directory                 "
	echo "        -h --history      show the last deletion               "
	echo "        -l --list         list all deleted files               "
	echo "        -r --remove       permanently remove all deleted files "
	echo "        -u --undo         undo the last deletion               "
	exit 0
}

### Main ######################################################################

_guard () { qq="'\''"; echo "'${1//\'/$qq}'"; }

set -e

true > "$DEL_HST"
for file in "$@"; do
	if [[ -f "$file" || -d "$file" ]]; then
		orig=$(_guard "$(realpath "$file")")
		dump=$(_guard "$DEL_DIR/$(basename "$file")")
		echo "$orig" "$dump" | xargs -n 2 mv
		echo "$dump	$orig" >> "${DEL_HST}"
	else
		if [[ "$file" =~ ^-{1,2}[a-z]+$ ]]; then
			echo "unrecognized flag."
		else
			echo "file '$file' not regular."
		fi
	fi
done

exit 0
