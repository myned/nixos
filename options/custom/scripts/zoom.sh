#! /usr/bin/env bash

# @describe Wrapper for zooming display
#
# https://github.com/sigoden/argc

# @arg factor=1.0 Absolute or relative factor to zoom to, empty to reset

eval "$(argc --argc-eval "$0" "$@")"

factor="$(hyprctl -j getoption cursor:zoom_factor | jq -r .float)" # Current factor

# Match regex for zero-padded decimals
if [[ "${argc_factor:-}" =~ ^[+|-][0-9]\.[0-9]+$ ]]; then
  factor="$(bc <<< "$factor ${argc_factor}")"
elif [[ "${argc_factor:-}" =~ ^[0-9]\.[0-9]+$ ]]; then
  factor="${argc_factor:-}"
else
  echo "Factor must be an absolute or relative decimal between 1.0 and 9.9"
  exit 1
fi

# Reset if outside range
if (("$(bc <<< "$factor < 1")")); then
  factor=1.0
fi

hyprctl keyword cursor:zoom_factor "$factor"
