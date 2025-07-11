#! /usr/bin/env bash

# @describe Toggle device pawdedness
#
# https://github.com/sigoden/argc

# BUG: New hyprctl syntax does not support per-device getoption
# https://github.com/hyprwm/hyprlang/issues/43
# HACK: Condition based on file presence, requires execution at reload to set state
#?? exec = left --init <DEVICE>

# @arg device! Device name, obtained via hyprctl devices
# @option -f --file=`_default_file` Specify file for state
# @flag -i --init Enforce file-based state without switching
# @flag -s --scroll Also invert scroll direction

_default_file() {
  echo "$HOME/.left"
}

eval "$(argc --argc-eval "$0" "$@")"

# Get initial state
if [[ -f "${argc_file:-}" ]]; then
  left=1
else
  left=0
fi

# If not initializing
if [[ ! "${argc_init:-}" ]]; then
  left=$((1 - "$left")) # Toggle 0/1
fi

# Enforce state
if (("$left")); then
  hyprctl keyword "device[${argc_device:-}]:left_handed" true

  if [[ "${argc_scroll:-}" ]]; then
    hyprctl keyword "device[${argc_device:-}]:natural_scroll" true
  fi

  touch "${argc_file:-}"

  if [[ ! "${argc_init:-}" ]]; then
    notify-send "> left" "Left-pawed" --urgency low
  fi
else
  hyprctl keyword "device[${argc_device:-}]:left_handed" false

  if [[ "${argc_scroll:-}" ]]; then
    hyprctl keyword "device[${argc_device:-}]:natural_scroll" false
  fi

  rm --force "${argc_file:-}"

  if [[ ! "${argc_init:-}" ]]; then
    notify-send "> left" "Right-pawed" --urgency low
  fi
fi
