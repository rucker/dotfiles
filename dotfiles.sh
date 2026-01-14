#!/bin/bash -e

declare -a ARGS
declare DOTFILES_SCRIPT_DIR
NO_PULL=false
THIS_SCRIPT=$(echo $(basename $([ -L $0 ] && readlink -f $0 || echo $0)))
declare DFM_OPTS
SCRIPT_OPTS=(-h --help -i --install --no-pull)

_usage() {
  echo -e "Usage: ${THIS_SCRIPT} ${SCRIPT_OPTS[@]} \n"
  echo "Dotfiles-Manager (dfm.py) wrapper script"
}

main() {
  if [[ $@ =~ -i || $@ =~ --install ]]; then
    _check_dependencies
    exit
  fi

  # Always check dependencies (dfm must be in PATH)
  _check_dependencies
  _get_dfm_opts
  _set_opts "$@"

  DOTFILES_SCRIPT_DIR=$(realpath $(dirname $([ -L $0 ] && readlink -f $0 || echo $0)))
  if [[ $NO_PULL = false ]]; then
    echo Updating dotfiles repo...
    _update_repo ${DOTFILES_SCRIPT_DIR}
    echo -e "Update complete. Running dfm \n"
  fi

  _run_dfm "${ARGS[@]}"
}

_get_dfm_opts() {
  DFM_OPTS=($(dfm --help | grep -v -E "\[" | grep -o -- "\s[-]\+[A-Za-z|-]\+"))
}

__present() {
  command -v ${1} >/dev/null 2>&1
  echo $?
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

_check_dependencies() {
  echo "Checking dependencies..."

  # Check if dfm is installed
  if ! command -v dfm &> /dev/null; then
    cat <<'EOF'
ERROR: 'dfm' command not found.

Please install dotfiles-manager:
  git clone https://github.com/rucker/dotfiles-manager.git
  cd dotfiles-manager
  python -m pip install --user -e .

This installs to ~/.local/bin/dfm (ensure ~/.local/bin is in your PATH)

Or install from PyPI (when available):
  python -m pip install --user dotfiles-manager
EOF
    exit 1
  fi

  # Create ~/bin if needed
  local home_bin=${HOME}/bin
  if [[ ! -d ${home_bin} ]]; then
    mkdir -p ${home_bin}
  fi

  # Create symlink for dotfiles wrapper (keep this)
  local dotfiles_link=${home_bin}/dotfiles
  local dotfiles_link_target=$(realpath ${BASH_SOURCE[0]})
  if [[ ! -e ${dotfiles_link} ]]; then
    ln -s ${dotfiles_link_target} ${dotfiles_link}
    echo "Created symlink: ${dotfiles_link} -> ${dotfiles_link_target}"
  fi
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
  local DFM_CMD="dfm ${DOTFILES_SCRIPT_DIR}/src"
  local os_excludes
  if [[ $(uname) =~ "Linux" ]]; then
    os_excludes=(96-bashrc_win 98-bashrc_mac 96-bashrc_mac)
  elif [[ $(uname) =~ "NT" ]]; then
    os_excludes=(96-bashrc_linux 98-bashrc_mac 96-bashrc_mac)
  elif [[ $(uname) == "Darwin" ]]; then
    os_excludes=(96-bashrc_win 96-bashrc_linux)
  else
    os_excludes=(96-bashrc_win 96-bashrc_linux 98-bashrc_mac 96-bashrc_mac)
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
  local known_excludes=( 96-bashrc_linux 98-bashrc_mac 96-bashrc_mac 96-bashrc_win doom.d backups scripts snippets )
  local local_excludes=($(echo $(cd "${DOTFILES_SCRIPT_DIR}/src" && ls *_local 2>/dev/null)))
  ${DFM_CMD} --no-symlinks ${known_excludes[@]/#/-e } ${local_excludes[@]/#/-e } -o ${DOTFILES_SCRIPT_DIR} ${args[@]}
  rm -r "${DOTFILES_SCRIPT_DIR}/.doom.d"
  cp -r "${DOTFILES_SCRIPT_DIR}/src/doom.d/" "${DOTFILES_SCRIPT_DIR}/.doom.d"
}

main "$@"
