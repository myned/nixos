#! /usr/bin/env bash

# Exec with mark if mark is not present in tree then go to workspace
#?? mark MARK COMMANDS

trap "notify-send '> mark' 󰃤" ERR

if ! swaymsg -t get_marks | grep "$1"; then
  swaymsg -- exec "${@:2}" || exit 1
  sleep 0.1
  swaymsg -- mark --replace "$1"
fi
