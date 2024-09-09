#! /usr/bin/env bash

# Toggle inhibit idle

if pkill systemd-inhibit; then
  notify-send '> inhibit' 'Stopped inhibiting' --urgency low
else
  notify-send '> inhibit' 'Inhibiting...' --urgency low
  systemd-inhibit --what idle:handle-lid-switch --who User --why 'User requested' sleep 1d
fi
