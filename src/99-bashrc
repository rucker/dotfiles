# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Begin auto start/attach tmux
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

__tmux-attach() {
  [[ ! -z $SSH_CONNECTION || $(__running_in_docker) == "true" || -z $(which tmux) || ! -z $TMUX_VERSION ]] && return
  local tmux_sessions=$(tmux list-sessions)
  if [[ -z ${tmux_sessions} ]]; then
    tmux
  else
    echo -e "Existing tmux session(s) found:\n"
    eval tmux list-sessions
    echo -e "\nYou can attach to one of these sessions via:"
    echo tmux a -t target-session
  fi
}

__tmux-attach
# End auto start/attach tmux

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Disable XON/XOFF flow control as it conflicts with readline i-search
stty -ixon

export EDITOR=vim
export VISUAL=${EDITOR}
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export LS_OPTIONS="-h --color=auto --group-directories-first"

__do_alias() {
    for prog in $(echo $2 | tr " " "\n"); do
        if [[ $prog == -* ]]; then
            continue
        elif [[ $(which $prog > /dev/null 2>&1; echo $?) -ne 0 ]]; then
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
  local OLDIFS=${IFS}
  IFS=$'\n'
  proc=($(ps -ef))
  shopt -s nocasematch
  for p in ${proc[@]}; do
    if [[ ${p} = UID* || ${p} =~ "${1}" ]]; then
      echo ${p}
    fi
  done
  shopt -u nocasematch
  IFS=${OLDIFS}
}

git-clone() {
  if [[ $# -eq 0 ]]; then
    git clone
  elif [[ $# -eq 1 ]]; then
    if git clone ${1}; then
      dirname=$(echo ${1##*/} | sed 's,.git,,')
      echo cd ${dirname}
      cd ${dirname}
    fi
  elif [[ $# -eq 2 ]]; then
    if git clone $@; then
      echo cd ${2}
      cd ${2}
    fi
  else
    echo "Usage: ${FUNCNAME[0]} <repository> [<directory>]"
    echo If you need to do something fancy, try a naked \'git clone\' instead.
  fi
}

git-push() {
  local push_res=$(git push 2>&1)
  echo
  if [[ ${push_res} =~ "no upstream branch" ]]; then
    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    local push_cmd="git push --set-upstream origin ${branch_name};"
    if [[ $# -eq 1 && $(echo $1) == -[Yy] ]]; then
      eval $push_cmd
    else
      printf '%s\n\n' "${push_res[@]}"
      while true; do
        read -p "Set upstream to origin/${branch_name} and push? [Y/N] " yn
        case ${yn} in
          [Yy]* ) echo; eval $push_cmd; break;;
          [Nn]* ) echo Abort.; break;;
          * ) echo Please enter Y or N
        esac
      done
    fi
  fi
}

up() {
  if [[ $# -eq 0 ]]; then
    cd ..
    return
  elif [[ $# -gt 1 ]]; then
    >&2 echo "Got too many args"
    >&2 echo "Usage: ${FUNCNAME[0]} [<number>]"
    return 1
  fi
  local idx=$1
  local cmd=""
  while [[ $idx -gt 0 ]]; do
    cmd="$cmd../"
    ((idx--))
  done
  eval "cd $cmd"
}

mkcd() {
  if [[ -z $1 ]]; then
   >&2 echo "Usage: mkcd DIRNAME"
   return 1
  fi

  mkdir "$1" && cd "$1"
}

latest() {
  local dir
  local results
  local USAGE="Usage: \n${FUNCNAME[0]} DIR NUMBER\n${FUNCNAME[0]} NUMBER\n${FUNCNAME[0]} DIR"

  if [[ $# -gt 2 ]]; then
    echo "Invalid arguments: ${@}" >&2
    echo -e "${USAGE}" >&2
    return 1
  fi

  if [[ $# -eq 1 ]]; then
    if [[ -d "${1}" ]]; then
      dir="${1}"
    elif [[ "${1}" =~ ^[0-9]+$ ]]; then
      results=$(("${1}" + 1)) #Bump to offset ls 'total' line
    else
      echo "Invalid number or dir name: ${1}" >&2
      echo -e "${USAGE}" >&2
      return 1
    fi
  fi

  if [[ $# -eq 2 ]]; then
    if [[ "${1}" =~ ^[0-9]+$ ]]; then
      results=$(("${1}" + 1)) #Bump to offset ls 'total' line
    else
      echo "Invalid number: ${1}" >&2
      echo -e "${USAGE}" >&2
      return 1
    fi
    if [[ -d "${2}" ]]; then
      dir="${2}"
    else
      echo "Cannot access '${2}': No such file or directory" >&2
      echo -e "${USAGE}" >&2
      return 1
    fi
  fi

  [[ -z ${results} ]] && results=11
  [[ -z ${dir} ]] && dir='.'
  [[ $(eval file -h "${dir}") =~ 'symbolic link' ]] && dir="${dir}/"
  [[ -z ${dir} ]] && dir="."

  ls -lAtc "${dir}" | head -n $results
}

umask 022

eval `dircolors`

alias grep="grep --color=auto"
alias hgrep="history | grep"
alias dmesg="dmesg -T --color=always"
alias pull="git pull"
alias co="git checkout"
alias st="git st"
alias lg="git lg -25"
alias rbi="git rebase -i"
alias gd="git diff"
alias gls="git ls"
alias gu="git upd"
alias ls="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -l"
alias l="ls $LS_OPTIONS -lA"
__do_alias "diff" "colordiff"
__do_alias "cat" "grc cat"
__build_ps1
