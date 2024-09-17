#! /usr/bin/env bash

# Toggle left-pawed mouse
#?? left DEVICE

# BUG: New hyprctl syntax does not support per-device getoption
# https://github.com/hyprwm/hyprlang/issues/43
# HACK: Condition based on file presence, requires execution at reload to set state
#?? exec = left
FILE="$HOME/.left"

# Set initial state
if [[ -f "$FILE" ]]; then
  left=1
else
  left=0
fi

# If device argument, then toggle
if (("$#" > 0)); then
  left=$((1 - "$left"))
fi

# Enforce state
if (("$left")); then
  hyprctl keyword "device[$1]:left_handed" true
  hyprctl keyword "device[$1]:natural_scroll" true
  touch "$FILE"
  notify-send "> left" "Left-pawed" --urgency low
else
  hyprctl keyword "device[$1]:left_handed" false
  hyprctl keyword "device[$1]:natural_scroll" false
  rm --force "$FILE"
  notify-send "> left" "Right-pawed" --urgency low
fi
