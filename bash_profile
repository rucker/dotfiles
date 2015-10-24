#!/bin/bash
# ~/.bash_profile: executed by bash(1) for non-login shells.
# This file was generated by a script. Do not edit manually!

goToFirstCol="\[\033[G\]"
green="\[\033[1;32m\]"
blue="\[\033[1;34m\]"
magenta="\[\033[1;35m\]"
default="\[\033[00m\]"
timestamp="[\D{%Y-%m-%d} \t]"

PS1="$goToFirstCol$timestamp$green\u@\h$blue \w"
if [ -f ~/code/scripts/git-prompt.sh ]; then
  source ~/code/scripts/git-prompt.sh
  PS1=$PS1"$magenta$(__git_ps1)"
fi
export PS1=$PS1"$blue\n\$$default "

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
if [ -f ~/.sdkman/bin/sdkman-init.sh ]; then
  source ~/.sdkman/bin/sdkman-init.sh
fi
