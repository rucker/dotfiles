#!/bin/bash

NO_PULL=false
declare -a ARGS

main() {
    _set_args "$@"
    DOTFILES_SCRIPT_DIR="$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))"
    DFM_SCRIPT=$(readlink ${HOME}/bin/dfm)
    if [[ -z ${DFM_SCRIPT} ]]; then
        echo dfm not found on '$PATH'.
        exit 1
    fi

    if [[ $NO_PULL = false ]]; then
        echo Updating repos...
        _update_repo ${DOTFILES_SCRIPT_DIR}
        _update_repo $(dirname ${DFM_SCRIPT})
        echo Updates complete. Running dfm
        echo
    fi

    _run_dfm "${ARGS[@]}"
}

_set_args() {
    while [[ $# -ge 1 ]]; do
        arg="$1"
        case "${arg}" in
            --no-pull)
                NO_PULL=true
                shift
                ;;
            *)
              if ! [[ "$2" =~ - ]]; then
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

_update_repo() {
    pushd $1 &> /dev/null
    if [[ -z $(git status --porcelain) ]]; then
        echo Pulling $1
        git pull
    else
        echo $1 contains unstaged changes. Skipping pull
    fi
    popd &> /dev/null
    echo
}

_run_dfm() {
    local DFM_CMD="${DFM_SCRIPT} ${DOTFILES_SCRIPT_DIR}/src"
    local excludes
    if [[ $(uname) == "Linux" || $(uname) =~ "NT" || ! -d /usr/local/opt/coreutils/libexec/gnubin/ ]]; then
        excludes=98-bashrc_mac
    else
        excludes=98-bashrc_linux
    fi

    $DFM_CMD -e ${excludes} $@

    # Update dotfiles in this repo for vanity purposes
    if [[ $# -eq 0 ]]; then
        ${DFM_SCRIPT} ${DOTFILES_SCRIPT_DIR}/src --no-symlinks -e gitconfig_local -e 98-bashrc_linux -e 98-bashrc_mac -e 97-bashrc_local -o ${DOTFILES_SCRIPT_DIR}
    fi
}

main "$@"
