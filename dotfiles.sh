#!/bin/bash

DIR="$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))"

dfm -i "$DIR/src" "$@"
if [[ $# -eq 0 ]]; then
    dfm -i "$DIR/src" --no-local -o $DIR 1>/dev/null
    if [[ `uname` == "Darwin" ]]; then
        dfm -i "$DIR/src" -f bashrc --no-local -o $DIR 1>/dev/null
    else
        dfm -i "$DIR/src" -f bash_profile --no-local -o $DIR 1>/dev/null
    fi
fi
