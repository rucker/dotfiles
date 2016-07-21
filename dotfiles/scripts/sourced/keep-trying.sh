#!/bin/bash

#TODO
# Help message
# Quit, print help message when too few parameters
# Quit when exit status 0
# Why didn't it work with "gimme" alias? Maybe it would work as "$($1)" or some such

# cmd, interval, max
function keep-trying {
    local idx=0
    local max=""
    if [[ $# -eq 2 ]]; then
        let max=99
    else
        let max=$3
    fi
    echo "Attempting: $1 at an interval of $2 seconds for a max of $max tries."
    while [[ $idx < $max ]]; do
        echo "$1"
        $1
        sleep $2
        let "$idx++"
        done
}
