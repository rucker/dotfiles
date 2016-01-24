#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# This file was generated by a script. Do not edit manually!

__doAlias() {
  for prog in $(echo $2 | tr " " "\n"); do
    if [[ "$(which $prog)" == "" ]]; then
      return
    fi
  done
  alias "$1"="$2"
}

__sourceInDir() {
  for s in $1*; do
    source $s
  done
}

goToFirstCol="\[\033[G\]"
green_bold="\[\033[1;32m\]"
blue_bold="\[\033[1;34m\]"
magenta_bold="\[\033[1;35m\]"
yellow_light="\[\033[0;33m\]"
default="\[\033[00m\]"
timestamp="[\D{%Y-%m-%d} \t]"

PS1="$goToFirstCol$yellow_light$timestamp $green_bold\u@\h$blue_bold \w"
if [[ $(type -t __git_ps1) == 'function' ]]; then
  PS1=$PS1"$magenta_bold$(__git_ps1)"
fi
export PS1=$PS1"$blue_bold\n\$$default "

umask 022

export LS_OPTIONS="-h --color=auto --group-directories-first"
 
alias ls="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -l"
alias l="ls $LS_OPTIONS -lA"
alias grep="grep --color=auto"
alias hgrep="history | grep"
alias dmesg="dmesg -T --color=always"
__doAlias "diff" "colordiff"
__doAlias "cat" "grc cat"
__doAlias "pbcopy" "xclip -selection c"
alias gimme="sudo apt-get install"
alias remove="sudo apt-get remove"
alias psgrep="ps -ef | grep"
eval `dircolors`
