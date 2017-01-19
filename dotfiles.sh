#!/bin/bash

DIR="$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))"

dfm -i "$DIR/src" "$@"
if [[ $# -eq 0 ]]; then
    dfm -i "$DIR/src" --no-local -o $DIR
fi
