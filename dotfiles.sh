#!/bin/bash

declare -a ARGS
declare DOTFILES_SCRIPT_DIR
NO_PULL=false
INSTALL=false
THIS_SCRIPT=$(echo $(basename $([ -L $0 ] && readlink -f $0 || echo $0)))
DFM_OPTS=($(dfm --help | grep -v -E "\[" | grep -o -- "\s[-]\+[Aa-Zz|-]\+"))
SCRIPT_OPTS=(-h --help -i --install --no-pull)

__usage() {
    echo -e "Usage: ${THIS_SCRIPT} ${SCRIPT_OPTS[@]} \n"
    echo "Dotfiles-Manager (dfm.py) wrapper script"
}


main() {
    _set_args "$@"
    [[ ${INSTALL} ]] && _install

    DOTFILES_SCRIPT_DIR="$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))"
    DFM_SCRIPT=$(readlink ${HOME}/bin/dfm)
    if [[ -z ${DFM_SCRIPT} ]]; then
        echo dfm not found on '$PATH'.
        exit 1
    fi

    if [[ $NO_PULL = false ]]; then
        echo Updating repos...
        repos=( ${DOTFILES_SCRIPT_DIR} $(dirname ${DFM_SCRIPT}) )
        for repo in ${repos[@]}; do
            _update_repo ${repo}
            local result=$?
            if [[ ${result} -ne 0 ]]; then
                echo There was a problem updating repo ${repo}. Abort
                exit 1
            fi
        done
        echo Updates complete. Running dfm
        echo
    fi

    _run_dfm "${ARGS[@]}"
}

_set_args() {
    while [[ $# -ge 1 ]]; do
        arg="$1"
        case "${arg}" in
            -h|--help)
                __usage
                exit;;
            --no-pull)
                NO_PULL=true
                shift
                ;;
            -i|--install)
                INSTALL=true
                shift
                ;;
            *)
                if [[ ! ${DFM_OPTS[@]} =~ ${arg} ]]; then
                    echo "Unrecognized option ${arg}"
                    __usage
                    exit
                fi
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

_install() {
}

_update_repo() {
    pushd $1 &> /dev/null
    echo $1
    if [[ -z $(git status --porcelain) ]]; then
        git pull
        if [[ $1 == ${DOTFILES_SCRIPT_DIR} ]]; then
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
    local DFM_CMD="${DFM_SCRIPT} ${DOTFILES_SCRIPT_DIR}/src"
    local exclude
    if [[ $(uname) == "Linux" || $(uname) =~ "NT" || ! -d /usr/local/opt/coreutils/libexec/gnubin/ ]]; then
        exclude=98-bashrc_mac
    else
        exclude=98-bashrc_linux
    fi

    ${DFM_CMD} -e ${exclude} $@

    # Update dotfiles in this repo for vanity purposes
    local args=( $@ )
        local idx=0
        while [[ ${idx} -lt ${#args[@]} ]]; do
            if [[ ${args[${idx}]} == "-o" ]]; then
                args[${idx} + 1]=${DOTFILES_SCRIPT_DIR}
                break;
            fi
            let idx++
        done
        local excludes=( -e gitconfig_local -e 98-bashrc_linux -e 98-bashrc_mac -e 97-bashrc_local -o  )
        ${DFM_SCRIPT} ${DOTFILES_SCRIPT_DIR}/src --no-symlinks ${excludes[@]} ${DOTFILES_SCRIPT_DIR} ${args[@]}
}

main "$@"
