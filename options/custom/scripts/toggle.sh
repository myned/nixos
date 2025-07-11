#! /usr/bin/env bash

# Toggle pinned window, launch if needed
#?? toggle --type TYPE --expression EXPRESSION --workspace WORKSPACE [COMMAND]
#!! Regex may need to be double-escaped
# https://jqlang.github.io/jq/manual/#regular-expressions

focus=false

while (("$#" > 0)); do
  case "$1" in
    -e | --expression)
      shift
      expression="$1"
      ;;
    -f | --focus)
      focus=true
      ;;
    -t | --type)
      shift
      type="$1"
      ;;
    -w | --workspace)
      shift
      workspace="$1"
      ;;
    --)
      shift
      break
      ;;
  esac
  shift
done

command="${*}"

if [[ "$command" ]]; then
  if ! hyprctl -j clients | jq -re "any(.[].$type | test(\"$expression\"); . == true)"; then
    hyprctl dispatch exec -- "$command" # Launch window
    exit
  fi
fi

current_workspace="$(hyprctl -j clients | jq -r "first(.[] | select(.$type | test(\"$expression\")).workspace.name)")"

if [[ "$current_workspace" == "$workspace" ]]; then
  # HACK: Move to current workspace before pinning, otherwise some windows freeze
  # https://github.com/hyprwm/Hyprland/issues/7609
  # https://github.com/hyprwm/Hyprland/issues/7191
  #// hyprctl dispatch movetoworkspacesilent "0,$type:$expression"

  hyprctl dispatch pin "$type:$expression" # Pin

  if "$focus"; then
    hyprctl dispatch focuswindow "$type:$expression" # Focus
  fi
else
  hyprctl dispatch pin "$type:$expression" # Unpin
  hyprctl dispatch movetoworkspacesilent "$workspace,$type:$expression" # Move to workspace
fi
