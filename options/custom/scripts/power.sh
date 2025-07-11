#! /usr/bin/env bash

# Toggle power-saver mode

if [[ "$(powerprofilesctl get)" == 'power-saver' ]]; then
  powerprofilesctl set balanced
  notify-send '> power' 'Balanced' --urgency low
else
  powerprofilesctl set power-saver
  notify-send '> power' 'Power Saver' --urgency low
fi
