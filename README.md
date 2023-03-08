# del: a minimal and safe way of deleting

`del` is an alternative command line tool to `rm` that makes deleting files safer.
`del` is similar to [`trash-cli`](https://github.com/andreafrancia/trash-cli),
but implemented in less than 100 lines of bash script.

## Installation

Download the script `del.sh` and make a link using
```sh
ln -si path/to/del.sh /usr/local/bin/del
```
where `path/to/del.sh` is the path to the downloaded script.

## Usage

```
usage: del [options] [file ...]
options:
        -d --directory    show trash directory
        -h --history      show the last deletion
        -l --list         list all deleted files
        -r --remove       permanently remove all deleted files
        -u --undo         undo the last deletion
```

- To remove a file, simply do `del file`.
- To show the trash directory, do `del -d` or `del --directory`.
- To show the last deletion, do `del -h` or `del --history`.
- To list all the deleted files, do `del -l` or `del --list`.
- To permanently remove all deleted files, do `del -r` or `del --remove`.
- To undo the last deletion, do `del -u` or `del --undo`.
  Only the latest deletion is remembered by `del`.

## Settings

There are three variables that can be customized:

- `DEL_DIR`: designate the trash location/directory. (default: `DEL_DIR="$HOME/.del"`)
- `DEL_HST`: designate a file that stores `del`'s history. (default: `DEL_HST="$HOME/.del/.del_history"`)
- `DEL_LST`: designate a command that lists the deleted files. (default: `DEL_LST="find"`)

## Tip

Typing `del` every time is exhausting.
Put
```sh
alias 'd'='del'
```
in your `.bashrc` and simply use `d` to delete!

It is **not** recommended that you alias `rm` to `del`.
This prevents you from using `rm` without thinking, especially on another machine that does not have the alias.
I recommend [this tip from `trash-cli`](https://github.com/andreafrancia/trash-cli#but-sometimes-i-forget-to-use-trash-put-really-cant-i)
to break the habit of using `rm` all the time.

## License

License: GPL-3</br>
Copyright 2022 Jesse C. Chen
