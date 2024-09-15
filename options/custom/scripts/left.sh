#! /usr/bin/env bash

# Toggle left-handed mouse
#?? left DEVICE

# BUG: New hyprctl syntax does not support per-device getoption
# https://github.com/hyprwm/hyprlang/issues/43
# HACK: Condition based on file presence, requires creation at login to set state
#?? exec-once = left
FILE=/tmp/left

if (("$#" == 0)); then
  touch "$FILE"
  exit
fi

if [[ -f "$FILE" ]]; then
  hyprctl keyword "device[$1]:left_handed" false
  hyprctl keyword "device[$1]:natural_scroll" false
  rm --force "$FILE"
  notify-send "> left" "Right-handed" --urgency low
else
  hyprctl keyword "device[$1]:left_handed" true
  hyprctl keyword "device[$1]:natural_scroll" true
  touch "$FILE"
  notify-send "> left" "Left-handed" --urgency low
fi
