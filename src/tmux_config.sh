#!/bin/bash

# tmux version-specific configs (source: http://stackoverflow.com/a/40902312)

found_bc=$(which bc 2>&1>/dev/null; echo $?)
if [[ $found_bc -eq 1 ]]; then
  tmux display-message "bc is not installed. Unable to evaluate tmux version"
else
  tmux setenv -g TMUX_VERSION $(tmux -V | cut -c 6-)
  if [ $(echo "$TMUX_VERSION < 2.1" | bc) = 1 ]; then
    tmux display-message "TMUX_VERSION < 2.1"
    tmux set -g mouse-select-pane on; tmux set -g mode-mouse on
    tmux set -g mouse-resize-pane on; tmux set -g mouse-select-window on
  fi

  # In version 2.1 "mouse" replaced the previous 4 mouse options
  if [ "$(echo "$TMUX_VERSION >= 2.1" | bc)" = 1 ]; then
    tmux display-message "TMUX_VERSION >= 2.1"
    tmux set -g mouse on
  fi

  # UTF8 is autodetected in 2.2 onward, but errors if explicitly set
  if [ "$(echo "$TMUX_VERSION < 2.2" | bc)" = 1 ]; then
    tmux display-message "TMUX_VERSION < 2.2" 
    tmux set -g utf8 on; tmux set -g status-utf8 on; tmux set -g mouse-utf8 on
  fi
fi
