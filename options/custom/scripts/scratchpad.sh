#! /usr/bin/env bash

# Toggle scratchpad window and launch with mark if needed
#?? scratchpad MARK COMMANDS

trap "notify-send '> scratchpad' 󰃤" ERR

mark "$@" &&
  sleep 0.1 # Ensure surface is created

swaymsg "[con_mark=$1] scratchpad show"
