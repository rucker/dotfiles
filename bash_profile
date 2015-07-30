#!/bin/bash
# ~/.bash_profile: executed by bash(1) for non-login shells.
# This file was generated by a script. Do not edit manually!

PS1="\[\033[G\]\[\033[01;32m\]\u@\h\[\033[01;34m\] \w"
if [ -f ~/code/scripts/git-prompt.sh ]; then
  source ~/code/scripts/git-prompt.sh
  PS1=$PS1"\[\033[0;35m\]\$(__git_ps1)\[\033[01;34m\]"
fi
export PS1=$PS1"\$\[\033[00m\] "

umask 022

export LS_OPTIONS='-h --color=auto --group-directories-first'
 
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias diff='colordiff'
alias grep='grep --color=auto'
alias dmesg='dmesg -T'

export GRAILS_HOME=~/.gvm/grails/current
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home/
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$GRAILS_HOME/bin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
eval `dircolors`
alias htop='sudo htop'
