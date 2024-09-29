#! /usr/bin/env bash

# @describe Wrapper for toggling last special workspace
#
# https://github.com/sigoden/argc

# @meta combine-shorts
# @option -f --file=`_default_file` File to save last special workspace

_default_file() {
  echo "/tmp/workspace"
}

eval "$(argc --argc-eval "$0" "$@")"

# Get current special workspace from active monitor, empty if not toggled
workspace="$(hyprctl -j monitors | jq -r ".[] | select(.focused == true).specialWorkspace.name")"

# If empty, use saved file
if ! [[ "$workspace" ]] && [[ -f "${argc_file:-}" ]]; then
  workspace="$(cat "${argc_file:-}")"
fi

if [[ "$workspace" ]]; then
  # Toggle workspace
  hyprctl dispatch togglespecialworkspace "${workspace#special:*}" # Strip prefix

  # Save last workspace
  echo "$workspace" > "${argc_file:-}"
else
  notify-send "> workspace" "Last workspace not yet saved"
fi
