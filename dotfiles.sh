#!/bin/bash

main() {
    DOTFILES_SCRIPT_DIR="$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))"
    DFM_SCRIPT=$(readlink ${HOME}/bin/dfm)
    if [[ -z ${DFM_SCRIPT} ]]; then
        echo dfm not found on '$PATH'.
        exit 1
    fi

    echo Updating repos...
    _update_repo ${DOTFILES_SCRIPT_DIR}
    _update_repo $(dirname ${DFM_SCRIPT})
    echo Updates complete. Running dfm
    echo

    run_dfm "$@"
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

run_dfm() {
    if [[ $(uname) == "Darwin" ]]; then
        ${DFM_SCRIPT} ${DOTFILES_SCRIPT_DIR}/src -e 98-bashrc_linux $@
    else
        ${DFM_SCRIPT} ${DOTFILES_SCRIPT_DIR}/src -e 98-bashrc_mac $@
    fi

    # Update dotfiles in this repo for vanity purposes
    if [[ $# -eq 0 ]]; then
        ${DFM_SCRIPT} ${DOTFILES_SCRIPT_DIR}/src -e gitconfig_local -e 98-bashrc_linux -e 98-bashrc_mac -e 97-bashrc_local -o ${DOTFILES_SCRIPT_DIR}
    fi
}

main "$@"
