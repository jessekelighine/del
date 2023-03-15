#!/usr/bin/env bash

_redump () {
	local file; file=$( basename "$1" )
	local dirn; dirn=$( dirname  "$1" ) # there is an edge case where "$dirn" == "/"
	local body; body="${file%%.*}"
	local extn; extn="${file#$body}"
	if [[ ! -z "$body" ]]; then
		redump="$dirn/$body-$2$extn"
	else
		_redump "${extn:1}" "$2"
		redump="$dirn/.$(basename "$redump")"
	fi
}

files=(
	"/home/me/.Trash/This File/hello"
	"/home/me/.Trash/This File/ hello"
	"/home/me/.Trash/This File/hello world"
	"/home/me/.Trash/This File/hello's"
	"/home/me/.Trash/This File/hello.hello world"
	"/home/me/.Trash/This File/.hello.vim"
	"/home/me/.Trash/This File/.hello"
	"/home/me/.Trash/This File/..hello"
	"/home/me/.Trash/This File/#"
	"/home/me/.Trash/This File/%"
	"/home/me/.Trash/.%"
	"/home/me/.Trash/./%"
	"/home/me/.Trash/"
	"/home/me/.Trash//hi"
)

for file in "${files[@]}"; do
	_redump "$file" "0000"
	echo "$redump"
done
