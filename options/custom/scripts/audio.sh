#! /usr/bin/env bash

if [[ -v 1 ]]; then
  easyeffects --load-preset "$1" &&
    easyeffects --bypass 2
  notify-send '> audio' "$1" --urgency low
else
  easyeffects --load-preset Flat &&
    easyeffects --bypass 1
  notify-send '> audio' 'Bypass' --urgency low
fi
