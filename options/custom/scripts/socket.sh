#! /usr/bin/env bash

# Wrap commands in sway socket
# https://wiki.archlinux.org/title/Sway#Sway_socket_not_detected

pid="$(pgrep -x sway)"
uid="$(id -u)"

export SWAYSOCK=/run/user/"$uid"/sway-ipc."$uid"."$pid".sock
# TODO: Add Hyprland socket

"$@"
