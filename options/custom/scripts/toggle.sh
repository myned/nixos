#! /usr/bin/env bash

# Toggle tagged window, launch if needed
#?? toggle TAG WORKSPACE [COMMAND]
# TODO: Use proper flags
# TODO: Support floating groups

if (("$#" >= 3)); then
  # Launch if tag does not exist yet
  if ! hyprctl -j clients | jq -r '.[].tags[]' | grep "$1"; then
    hyprctl dispatch exec -- "${@:3}"
    exit
  fi
fi

# Dispatchers do not currently support matching by tag, so select address
window="address:$(hyprctl -j clients | jq -r "first(.[] | select(.tags[] | startswith(\"$1\")).address)")"

workspace="$(hyprctl -j clients | jq -r "first(.[] | select(.tags[] | startswith(\"$1\")).workspace.name)")"

if [[ "$workspace" == "$2" ]]; then
  hyprctl dispatch pin "$window" # Pin
  (("$#" >= 3)) && hyprctl dispatch focuswindow "$window" # Focus if third argument
else
  hyprctl dispatch pin "$window" # Unpin
  hyprctl dispatch movetoworkspacesilent "$2,$window"
fi
