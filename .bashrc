# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

__present() {
  command -v ${1} >/dev/null 2>&1
  echo $?
}

# Begin auto start/attach tmux
__running_in_docker() {
  if [[ -f /proc/self/cgroup ]]; then
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
  [[ ! -z $SSH_CONNECTION || $(__running_in_docker) == "true" || $(__present tmux) -ne 0 || ! -z $TMUX_VERSION ]] && return
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
export LS_OPTIONS="-h --color --group-directories-first"

__do_alias() {
    for prog in $(echo $2 | tr " " "\n"); do
        if [[ $prog == -* ]]; then
            continue
        elif [[ $(__present ${prog}) -ne 0 ]]; then
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
   local GO_TO_FIRST_COL="\[\033[G\]"
   local GREEN_BOLD="\[\033[1;32m\]"
   local BLUE_BOLD="\[\033[1;34m\]"
   local MAGENTA_BOLD="\[\033[1;35m\]"
   local YELLOW="\[\033[0;33m\]"
   local DEFAULT_COLOR="\[\033[00m\]"
   local TIMESTAMP="[\D{%Y-%m-%d} \t]"

    $(__running_in_docker) -eq true && hostname="docker" || hostname="\h"

    PS1="$GO_TO_FIRST_COL$YELLOW$TIMESTAMP $GREEN_BOLD\u@$hostname$BLUE_BOLD \w"
    if [[ $(type -t __git_ps1) == 'function' ]]; then
      PS1="$PS1$MAGENTA_BOLD\$(__git_ps1)"
    fi
    export PS1=$PS1"$BLUE_BOLD\012\$$DEFAULT_COLOR "
}

psgrep() {
  local OLDIFS=${IFS}
  IFS=$'\n'
  proc=($(ps -ef))
  echo ${proc[0]}
  let idx=1
  shopt -s nocasematch
  while [[ ${idx} -lt ${#proc[@]} ]]; do
    p=${proc[${idx}]}
      if [[ ${p} =~ ${1} ]]; then
        echo ${p} | grep --color=always ${1}
      fi
      ((idx++))
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
  if [[ "$#" -ne 1 ]]; then
   >&2 echo "Usage: mkcd DIRNAME"
   return 1
  fi

  mkdir "$1" && cd "$1"
}

mvcd() {
  local usage="Usage: mvcd [name|pattern] dest"
  local file_args=()
  local dest

  if [[ "$#" -lt 2 ]]; then
    >&2 echo ${usage}
    return 1
  fi

  if [[ "$#" -eq 2 ]]; then
    file_args+=("${1}")
    dest="${2}"
  else
    while [[ "$#" -gt 0 ]]; do
      if [[ -f "${1}" ]]; then
        file_args+=("${1}")
        shift
        continue
      elif [[ -d "${1}" ]]; then
        dest="${1}"
        shift
        continue
      else
        >&2 echo ${usage}
        return 1
      fi
    done
  fi

  echo "${file_args[@]}" "${dest}"
  mv "${file_args[@]}" "${dest}" && cd "${dest}"
}

# NOTE: Keep this function creation before aliasing of ls to use $LS_OPTIONS
latest() {
  local dirs=()
  local results
  local opts
  local USAGE="Usage: latest [OPTION]... [DIR]... [NUMBER]\n"
  USAGE+="List most recently modified entries in DIR(s) (the current directory by default), "
  USAGE+="limited to NUMBER of results (10 by default).\n"
  USAGE+="  -a --all\tEquivalent to ls -A --almost-all\n"
  USAGE+="  -h --help\tDisplay this help message"

  while [[ $# -gt 0 ]]; do
    case ${1} in
      -h|--help)
        echo -e ${USAGE}
        return 0
        ;;
      -a|--all)
        opts+=A
        shift
        ;;
      *)
        if [[ -d "${1}" ]]; then
          dirs+=("${1}")
        elif [[ "${1}" =~ ^[0-9]+$ ]]; then
          results=$(("${1}" + 1)) #Bump to offset ls 'total' line
        else
          echo "Invalid parameter: ${1}" >&2
          echo -e "${USAGE}" >&2
          return 1
        fi
        shift
      ;;
    esac
  done

  [[ -z ${results} ]] && results=11
  [[ -z ${dirs} ]] && dirs+=('.')

  local ls_latest_opts=$(echo $LS_OPTIONS | sed 's,--group-directories-first,,')

  let idx=0
  for dir in ${dirs[@]}; do
    [[ ${idx} -gt 0 ]] && echo ""
    echo ${dir}:
    [[ $(file -h "${dir}") =~ 'symbolic link' ]] && dir="${dir}/"
    ls -ltc${opts} ${ls_latest_opts} "${dir}" | head -n ${results}
    ((idx++))
  done
}

umask 022

alias grep="grep --color=auto"
alias hgrep="history | grep"
alias dmesg="dmesg -T --color=always"
alias pull="git pull"
alias co="git checkout"
alias st="git st"
alias lg="git lg -20"
alias rbi="git rebase -i"
alias gd="git diff"
alias gls="git ls"
alias gu="git upd"
alias gcm="git cm"
alias gcam="git cam"
alias gcane="git cane"
alias ls="ls $LS_OPTIONS"
alias ll="ls $LS_OPTIONS -l"
alias l="ls $LS_OPTIONS -lA"
alias resolution="mediainfo --Inform='Video;%Width%X%Height%'"
alias diff="diff --color"
__do_alias "cat" "grc cat"
export PATH=$HOME/bin:$HOME/.emacs.d/bin:$PATH
export LESS_TERMCAP_mb=$(printf "\e[1;31m")
export LESS_TERMCAP_md=$(printf "\e[1;31m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")
scripts_dir="$HOME/repos/dotfiles/src/scripts"
__source_in_dir $scripts_dir"/sourced/"
__source_in_dir $scripts_dir"/sourced-local/"
__build_ps1

