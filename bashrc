#!/bin/bash
# ~/.bash_profile: executed by bash(1) for lon-login shells.
# This file was generated by a script. Do not edit manually!

export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] "
umask 022

export LS_OPTIONS='-h --color=auto --group-directories-first'
 
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias diff='colordiff'
alias grep='grep --color=auto'
alias pbcopy='xclip -selection c'
alias dmesg='dmesg -T'
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
eval `dircolors`
alias htop='sudo htop'
