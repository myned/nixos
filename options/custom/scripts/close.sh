#! /usr/bin/env bash

# Close all windows

# Gather windows with classes
# If they don't have classes, ¯\_(ツ)_/¯
clients="$(hyprctl clients -j | jq -j '.[] | if .class != "" then "\(.pid) " else empty end')"

notify-send '> close' 'Killing open windows...' --urgency low

kill "$clients"
