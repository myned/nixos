#! /usr/bin/env bash

# https://github.com/dongdigua/configs/blob/main/sway/scripts/workspace.sh

trap "notify-send '> workspace' 󰃤" ERR

current_workspace="$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).current_workspace')"

if [[ "$1" == "prev" ]]; then
    to_workspace=$((current_workspace - 1))
elif [[ "$1" == "next" ]]; then
    to_workspace=$((current_workspace + 1))
fi

if (("$to_workspace" == 11)); then
    to_workspace=1
elif (("$to_workspace" == 0)); then
    to_workspace=10
fi

swaymsg workspace number "$to_workspace"
