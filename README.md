# `del`: a minimal and safe way of deleting

`del` is a simple script that makes deleting files safer.
`del` is similar to [`trash-cli`](https://github.com/andreafrancia/trash-cli),
but implemented in less than 100 lines of pure bash script.

# Installation

Download the script `del.sh` and make a link using
```sh
ln -si path/to/del.sh /usr/local/bin/del
```
where `path/to/del.sh` is the path to the downloaded script.

# Usage

```
usage: del [-dhlru] [file ...]
flags:
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

# Settings

There are three variables that can be customized:

- `DEL_DIR`: designate the trash location/directory.
- `DEL_HST`: designate a file that stores `del`'s history.
- `DEL_LST`: designate a command that lists the deleted files.

You can simply use the default values by not assigning the variables.
Or ,for example, you can put
```sh
export DEL_DIR="$HOME/.del"
export DEL_HST="$DEL_DIR/.del_undo"
export DEL_LST='ls -a'
```
in your `.bashrc`.

# Tip

Typing `del` every time is exhausting.
Put
```sh
alias 'd'='del'
```
in your `.bashrc` and simply use `d` to delete!

# License

License: GPL-3</br>
Copyright 2022 Jesse C. Chen
