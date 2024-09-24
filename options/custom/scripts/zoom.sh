#! /usr/bin/env bash

# @describe Wrapper for zooming display
#
# https://github.com/sigoden/argc

# @arg factor=1 Absolute or relative factor to zoom to, empty to reset

eval "$(argc --argc-eval "$0" "$@")"

factor="$(hyprctl -j getoption cursor:zoom_factor | jq -r .float)" # Current factor

if [[ "${argc_factor:-}" =~ ^[+|-][1-9]\.*[0-9]*$ ]]; then
  factor="$(bc <<< "$factor ${argc_factor}")"
elif [[ "${argc_factor:-}" =~ ^[1-9]\.*[0-9]*$ ]]; then
  factor="${argc_factor:-}"
else
  echo "Factor must be an absolute or relative decimal between 1 and 9"
  exit 1
fi

hyprctl keyword cursor:zoom_factor "$factor"
