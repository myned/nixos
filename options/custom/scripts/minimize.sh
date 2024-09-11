#! /usr/bin/env bash

# Minimize/unminimize active window

# Get active workspace
workspace="$(hyprctl activewindow -j | jq -r .workspace.name)"

if [[ "$workspace" == "special:scratchpad" ]]; then
  hyprctl dispatch movetoworkspacesilent 0
else
  hyprctl dispatch movetoworkspacesilent special:scratchpad
fi
