#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# This file was generated by a script. Do not edit manually!

scriptsDir="/home/rick/code/dotfiles/dotfiles/scripts/"

for s in "$scriptsDir"*; do
  source "$s"
done

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

do_alias() {
  if [[ "$(which $2)" != "" ]]; then
    alias "$1"="$2"
  fi
}

umask 022

export LS_OPTIONS="-h --color=auto --group-directories-first"
 
alias ls="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -l"
alias l="ls $LS_OPTIONS -lA"
do_alias "diff" "colordiff"
alias grep="grep --color=auto"
alias hgrep="history | grep"
alias dmesg="dmesg -H"
alias proc="ps -ef | grep"
do_alias "pbcopy" "xclip -selection c"
alias gimme="sudo apt-get install"
alias remove="sudo apt-get remove"
eval `dircolors`
