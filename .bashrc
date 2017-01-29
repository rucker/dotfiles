#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# This file was generated by a script. Do not edit manually!

__do_alias() {
  for prog in $(echo $2 | tr " " "\n"); do
    if [[ $prog == -* ]]; then
      continue
    elif [[ "$(which $prog)" == "" ]]; then
      return
    fi
  done
  alias "$1"="$2"
}

__source_in_dir() {
  if [[ -d $1 && "$(ls -A $1)" ]]; then
    for s in $1*; do
      source $s
    done
  fi
}

__running_in_docker() {
    awk -F/ '$2 == "docker"' /proc/self/cgroup | read
}

man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
            man "$@"
}

GO_TO_FIRST_COL="\[\033[G\]"
GREEN_BOLD="\[\033[1;32m\]"
BLUE_BOLD="\[\033[1;34m\]"
MAGENTA_BOLD="\[\033[1;35m\]"
YELLOW="\[\033[0;33m\]"
DEFAULT_COLOR="\[\033[00m\]"
TIMESTAMP="[\D{%Y-%m-%d} \t]"

`__running_in_docker` && hostname="docker" || hostname="\h"

PS1="$GO_TO_FIRST_COL$YELLOW$TIMESTAMP $GREEN_BOLD\u@$hostname$BLUE_BOLD \w"
if [[ $(type -t __git_ps1) == 'function' ]]; then
  PS1=$PS1"$MAGENTA_BOLD\$(__git_ps1)"
fi
export PS1=$PS1"$BLUE_BOLD\n\$$DEFAULT_COLOR "
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

umask 022

alias grep="grep --color=auto"
alias hgrep="history | grep"
alias psgrep="ps -ef | grep -v grep | grep"
alias dmesg="dmesg -T --color=always"
alias pull="git pull"
alias co="git checkout"
alias st="git st"
alias lg="git lg -25"
alias rbi="git rebase -i"
alias gd="git diff"
__do_alias "diff" "colordiff"
__do_alias "cat" "grc cat"
__do_alias "pbcopy" "xclip -selection c"
alias gimme="sudo apt-get install"
alias remove="sudo apt-get remove"
eval `dircolors`

export LS_OPTIONS="-h --color=auto --group-directories-first"
alias ls="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -l"
alias l="ls $LS_OPTIONS -lA"
