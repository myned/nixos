#! /usr/bin/env bash

# Toggle left-handed mouse
# TODO: Make device-specific when commit released
# https://github.com/hyprwm/hyprlang/commit/95471ec86f37acb8281062e54e2be99b24b50cd0

left=$(("$(hyprctl getoption input:left_handed -j | jq '.int')" - 1))

hyprctl keyword input:left_handed ${left#-}

if [[ "$(hyprctl getoption input:left_handed -j | jq '.int')" == 1 ]]; then
  notify-send '> left' 'Left-handed' --urgency low
else
  notify-send '> left' 'Right-handed' --urgency low
fi
