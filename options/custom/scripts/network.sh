#! /usr/bin/env bash

# Toggle networking on/off

if [[ "$(nmcli networking connectivity)" == 'none' ]]; then
  nmcli networking on
else
  nmcli networking off
fi
