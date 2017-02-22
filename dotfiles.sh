#!/bin/bash

SCRIPT_DIR="$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))"

DFM=~/bin/dfm
DFM_SCRIPT=$(readlink $DFM)
if [[ -z $DFM_SCRIPT ]]; then
    echo dfm not found on '$PATH'.
    exit 1
fi

$DFM_SCRIPT -i "$SCRIPT_DIR/src" "$@"
if [[ $# -eq 0 ]]; then
    $DFM_SCRIPT -i "$SCRIPT_DIR/src" --no-local -o $SCRIPT_DIR 1>/dev/null
    if [[ $(uname) == "Darwin" ]]; then
        $DFM_SCRIPT -i "$SCRIPT_DIR/src" -f bashrc --no-local -o $SCRIPT_DIR 1>/dev/null
    else
        $DFM_SCRIPT -i "$SCRIPT_DIR/src" -f bash_profile --no-local -o $SCRIPT_DIR 1>/dev/null
    fi
fi
