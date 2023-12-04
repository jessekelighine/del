# del: a minimal and safe way of deleting

`del` is a **safe** alternative command line tool to `rm`.
`del` is similar to [`trash-cli`](https://github.com/andreafrancia/trash-cli),
but implemented in about 100 lines of bash script.

## Installation

Everything is self-contained in the bash script `del.sh`.
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
        -r --remove       permanently remove all deleted files (plz don't use this)
        -u --undo         undo the last deletion
```

- To remove a file, do `del file`.
- To show the trash directory, do `del -d` or `del --directory`.
- To show the last deletion, do `del -h` or `del --history`.
- To list all the deleted files, do `del -l` or `del --list`.
- To permanently remove all deleted files, do `del -r` or `del --remove`.
- To undo the last deletion, do `del -u` or `del --undo`.
  **Note**: Only the last deletion is remembered by `del`, i.e., you can only undo *once*.

## Settings

There are three variables that can be customized:

- `DEL_DIR`: designate the trash location/directory. (default: `DEL_DIR="$HOME/.del"`)
- `DEL_HST`: designate a file that stores `del`'s history. (default: `DEL_HST="$HOME/.del/.del_history"`)
- `DEL_LST`: designate a command that lists the deleted files. (default: `DEL_LST="find"`)

## Tip

### Alias

Typing `del` is exhausting.
Put
```sh
alias 'd'='del'
```
in your `.bashrc` and simply use `d` to delete!

It is **not** recommended that you alias `rm` to `del` since this prevents you from using `rm` carefully.
This will ultimately lead to disaster on another machine that does not have this alias.
I recommend [this tip](https://github.com/andreafrancia/trash-cli#but-sometimes-i-forget-to-use-trash-put-really-cant-i)
from [`trash-cli`](https://github.com/andreafrancia/trash-cli)
to break the habit of using `rm` without thinking.

### Piping

If you pipe filenames to `del`, you will need `xargs`. E.g.,
```sh
ls ~/Desktop | xargs del
```
deletes everything on the desktop.

## License

License: GPL-3</br>
Copyright 2022-2023 Jesse C. Chen
