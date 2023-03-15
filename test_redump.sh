#!/usr/bin/env bash

_redump () {
	local file; file=$( basename "$1" )
	local dirn; dirn=$( dirname  "$1" ); [ "$dirn" = "/" ] && dirn="";
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
	"/home/This File/hello"
	"/home/This File/ hello"
	"/home/This File/hello world"
	"/home/This File/hello's"
	"/home/This File/hello.hello world"
	"/home/This File/.hello.vim"
	"/home/This File/.hello"
	"/home/This File/..hello"
	"/home/This File/#"
	"/home/This File/%"
	".%"
	"./%"
	"/home"
	"/home/hi"
)

for file in "${files[@]}"; do
	_redump "$file" "0000"
	echo "$redump"
done
