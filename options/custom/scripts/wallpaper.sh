#! /usr/bin/env bash

# Wallpaper switcher
#?? wallpaper DIRECTORY

INTERVAL=15 # Minutes/seconds between switches
WALLPAPER=/tmp/wallpaper.png # Path to copy original
ALTERED=/tmp/altered.png # Path to create altered image
STATIC=/srv/sites/wallpaper.bjork.gay/wallpaper.png # Path to static image on server

# Launch wallpaper daemon in background
swww-daemon &

# Delay before initial switch
sleep "$INTERVAL"s

while true; do
  # Select random image from argument directory
  cp "$(fd . -t file -e png -e jpg -e jpeg "${1:-$HOME/SYNC/owo/unsorted}" | shuf -n 1)" "$WALLPAPER"

  # Apply image alterations
  #// magick "$WALLPAPER" -brightness-contrast -50x-50 -blur x50 "$ALTERED"
  magick "$WALLPAPER" -brightness-contrast -50x-50 "$ALTERED"

  # Display altered wallpaper
  swww img "$ALTERED" --transition-type grow --transition-pos bottom --transition-fps 100

  # Send unaltered image to server in background
  #!! Hostname dependent
  rsync --chown caddy:caddy "$WALLPAPER" root@myne:"$STATIC" &

  sleep "$INTERVAL"m
done
