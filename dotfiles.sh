#!/bin/bash -e

declare -a ARGS
declare DOTFILES_SCRIPT_DIR
NO_PULL=false
THIS_SCRIPT=$(echo $(basename $([ -L $0 ] && readlink -f $0 || echo $0)))
DFM=${HOME}/bin/dfm
declare DFM_OPTS
SCRIPT_OPTS=(-h --help -i --install --no-pull)

_usage() {
  echo -e "Usage: ${THIS_SCRIPT} ${SCRIPT_OPTS[@]} \n"
  echo "Dotfiles-Manager (dfm.py) wrapper script"
}

main() {
  if [[ $@ =~ -i || $@ =~ --install ]]; then
    _install
    exit
  fi

  if [[ ! -e ${DFM} ]]; then
    echo "dfm not found in ${HOME}/bin. Run with -i | --install to install."
    _usage
    exit 1
  else
    _get_dfm_opts
    _set_opts "$@"
  fi

  DOTFILES_SCRIPT_DIR=$(realpath $(dirname $([ -L $0 ] && readlink -f $0 || echo $0)))
  if [[ $NO_PULL = false ]]; then
    echo Updating repos...
    repos=( ${DOTFILES_SCRIPT_DIR} $(dirname $(readlink ${DFM})) )
    for repo in ${repos[@]}; do
      _update_repo ${repo}
    done
    echo -e "Updates complete. Running dfm \n"
  fi

  _run_dfm "${ARGS[@]}"
}

_get_dfm_opts() {
  DFM_OPTS=($(${DFM} --help | grep -v -E "\[" | grep -o -- "\s[-]\+[A-Za-z|-]\+"))
}

_set_opts() {
  while [[ $# -ge 1 ]]; do
    arg="$1"
    case "${arg}" in
      -h|--help)
        _usage
        exit;;
      --no-pull)
        NO_PULL=true
        shift
        ;;
      -i|--install)
        shift
        ;;
      *)
        if [[ ! ${DFM_OPTS[@]} =~ ${arg} ]]; then
          echo "Unrecognized option ${arg}"
          _usage
          exit
        fi
        if [[ -n "$2" && ! "$2" =~ - ]]; then
          ARGS+=("$1" "$2")
          shift
        else
          ARGS+=("$1")
        fi
        shift
        ;;
    esac
  done
}

_install() {
  echo Installing...
  local repos_dir=$(dirname $(dirname $(realpath BASH_SOURCE[0])))

  if [[ ! -d ${repos_dir} ]]; then
    echo Creating ${repos_dir}
    mkdir ${repos_dir}
  fi

  pushd ${repos_dir} 2>&1 > /dev/null

  if [[ ! -d dotfiles-manager ]]; then
    echo Cloning Dotfiles Manager
    git clone https://github.com/rucker/dotfiles-manager.git
  fi

  local home_bin=${HOME}/bin
  if [[ ! -d ${home_bin} ]]; then
    echo Creating ${home_bin}
    mkdir ${home_bin}
  fi

  if [[ -z $(readlink ${DFM}) ]]; then
    local dfm_link_target=${repos_dir}/dotfiles-manager/dotfilesmanager/dfm.py
    echo "Linking ${DFM} -> ${dfm_link_target}"
    ln -s ${dfm_link_target} ${DFM}
  fi

  local dotfiles_link=${home_bin}/dotfiles
  if [[ -z $(readlink ${dotfiles_link}) ]]; then
    local dotfiles_link_target=${repos_dir}/dotfiles/${THIS_SCRIPT}
    echo "Linking ${dotfiles_link} -> ${dotfiles_link_target}"
    ln -s ${dotfiles_link_target} ${home_bin}/dotfiles
  fi

  echo Installation complete

  popd 2>&1 > /dev/null

  _get_dfm_opts
}

_update_repo() {
  pushd $1 &> /dev/null
  echo $1
  if [[ -z $(git status --porcelain) ]]; then
    local commit_hash=$(git rev-parse HEAD)
    git pull
    if [[ $1 == ${DOTFILES_SCRIPT_DIR} && ${commit_hash} != $(git rev-parse HEAD) ]]; then
      local modified_in_head=$(git diff-tree --no-commit-id --name-only -r HEAD | grep -q ${THIS_SCRIPT}; echo $?)
      if [[ ${modified_in_head} -eq 0 ]]; then
        read -p "It looks like changes to this script were just pulled down. It is recommended that you exit now and re-run the script to pick up any changes. Exit now? [Y/N]: " answer
        while true; do
          case ${answer} in
            [Yy])
              echo Exit
              exit;;
            [Nn])
              echo Continuing along
              break;;
            *)
              read -p "Please enter Y or N: " answer
              ;;
          esac
        done
      fi
    fi

  else
    read -p "Repo contains unstaged changes. Pull and apply changes? [Y/N]: " answer
    while true; do
      case ${answer} in
        [Yy])
          local pull_cmd="git stash && git pull && git stash pop"
          echo -e "\n${pull_cmd}"
          eval ${pull_cmd}
          [[ $? -eq 0 ]] || return 1
          break;;
        [Nn])
          echo Skipping pull
          break;;
        *)
          read -p "Please enter Y or N: " answer
          ;;
      esac
    done

  fi
  popd &> /dev/null
  echo
}

_run_dfm() {
  local DFM_CMD="${DFM} ${DOTFILES_SCRIPT_DIR}/src"
  local os_excludes
  if [[ $(uname) =~ "Linux" ]]; then
    os_excludes=(98-bashrc_win 98-bashrc_mac)
  elif [[ $(uname) == "NT" ]]; then
    os_excludes=(98-bashrc_linux 98-bashrc_mac)
  elif [[ $(uname) == "Darwin" && -d /usr/local/opt/coreutils/libexec/gnubin/ ]]; then
    os_excludes=(98-bashrc_win 98-bashrc_linux)
  else
    os_excludes=(98-bashrc_win 98-bashrc_linux 98-bashrc-mac)
  fi

  ${DFM_CMD} ${os_excludes[@]/#/-e } $@

  # Update dotfiles in this repo for vanity purposes
  local args=( $@ )
  local idx=0
  while [[ ${idx} -lt ${#args[@]} ]]; do
    if [[ ${args[${idx}]} == "-o" ]]; then
      args[${idx} + 1]=${DOTFILES_SCRIPT_DIR}
      break
    fi
    ((idx++))
  done
  local known_excludes=( 98-bashrc_linux 98-bashrc_mac 98-bashrc_win )
  local local_excludes=($(echo $(cd "${DOTFILES_SCRIPT_DIR}/src" && ls *_local)))
  ${DFM_CMD} --no-symlinks ${known_excludes[@]/#/-e } ${local_excludes[@]/#/-e } -o ${DOTFILES_SCRIPT_DIR} ${args[@]}
}

main "$@"
