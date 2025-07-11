#! /usr/bin/env bash

# Toggle vrr

if [[ "$(hyprctl -j getoption misc:vrr | jq .int)" != 0 ]]; then
  hyprctl keyword misc:vrr 0
  notify-send '> vrr' 'Disabled' --urgency low
else
  hyprctl keyword misc:vrr 2
  notify-send '> vrr' 'Enabled' --urgency low
fi
