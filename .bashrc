#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.

__tmux-attach() {
  local OLDIFS=${IFS}
  IFS=$'\n'
  local tmux_sessions=($(tmux list-sessions))
  if [[ -z ${tmux_sessions} ]]; then
    tmux
  elif [[ ${#tmux_sessions[@]} -gt 1 ]]; then
    echo Multiple tmux sessions exist. Not attaching
  elif [[ ${tmux_sessions} =~ "attached" ]]; then
    echo One attached tmux session. Not attaching
  else
    tmux a
  fi
  IFS=${OLDIFS}
}

if [[ ! -z $(which tmux) && -z $TMUX_VERSION ]]; then
  __tmux-attach
fi

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
    if [[ -d /proc ]]; then
        awk -F/ '$2 == "docker"' /proc/self/cgroup | read
        if [[ $? -eq 0 ]]; then
            echo true
        else
            echo false
        fi
    else
        echo false
    fi
}

__build_ps1() {
    GO_TO_FIRST_COL="\[\033[G\]"
    GREEN_BOLD="\[\033[1;32m\]"
    BLUE_BOLD="\[\033[1;34m\]"
    MAGENTA_BOLD="\[\033[1;35m\]"
    YELLOW="\[\033[0;33m\]"
    DEFAULT_COLOR="\[\033[00m\]"
    TIMESTAMP="[\D{%Y-%m-%d} \t]"

    $(__running_in_docker) -eq true && hostname="docker" || hostname="\h"

    PS1="$GO_TO_FIRST_COL$YELLOW$TIMESTAMP $GREEN_BOLD\u@$hostname$BLUE_BOLD \w"
    if [[ $(type -t __git_ps1) == 'function' ]]; then
      PS1=$PS1"$MAGENTA_BOLD\$(__git_ps1)"
    fi
    export PS1=$PS1"$BLUE_BOLD\n\$$DEFAULT_COLOR "
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

psgrep() {
  OLDIFS=${IFS}
  IFS=$'\n'
  proc=($(ps -ef | grep -v grep | grep --color=never "UID\|${1}"))
  if [[ ${#proc[@]} > 1 ]]; then
    for line in ${proc[@]}; do
      echo $line
    done
  fi
  IFS=${OLDIFS}
}

git-clone() {
  git clone "$1"
  dirname=$(echo ${1##*/} | sed 's,.git,,')
  echo "cd ${dirname}"
  cd ${dirname}
}

git-push() {
  local push_res=$(git push 2>&1)
  printf '%s\n' "${push_res[@]}"
  echo
  if [[ ${push_res} =~ "no upstream branch" ]]; then
    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    while true; do
      read -p "Set upstream to origin/${branch_name} and push? [Y/N] " yn
      case ${yn} in
        [Yy]* ) git push --set-upstream origin ${branch_name}; git push; break;;
        [Nn]* ) break;;
        * ) echo "Please enter Y or N"
      esac
    done
  fi
}

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

umask 022

alias grep="grep --color=auto"
alias hgrep="history | grep"
alias dmesg="dmesg -T --color=always"
alias pull="git pull"
alias co="git checkout"
alias st="git st"
alias lg="git lg -25"
alias rbi="git rebase -i"
alias gd="git diff"
__do_alias "diff" "colordiff"
__do_alias "cat" "grc cat"
