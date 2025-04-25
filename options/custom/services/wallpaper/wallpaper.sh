#! /usr/bin/env bash

# Script to periodically switch wallpapers in given directory
#?? wallpaper <directory>

WALLPAPER=/tmp/wallpaper.png                                 # Path to copy original
ALTERED=/tmp/altered.png                                     # Path to create altered image
STATIC=srv@myne:/srv/sites/wallpaper.bjork.gay/wallpaper.png # Rsync URI to static image on remote server
INTERVAL=15                                                  # Minutes between switches

# Delay before initial switch
sleep 15s

while true; do
  # Select random image from argument directory
  cp "$(fd . -t file -e png -e jpg -e jpeg "${1:-$XDG_PICTURES_DIR}" | shuf -n 1)" "$WALLPAPER"

  # Apply image alterations
  #// magick "$WALLPAPER" -brightness-contrast -50x-50 -blur x50 "$ALTERED"
  magick "$WALLPAPER" -brightness-contrast -50x-50 "$ALTERED"

  # Display altered wallpaper
  swww img "$ALTERED" --transition-type grow --transition-pos bottom --transition-fps 100

  # Send unaltered image to server in background
  #!! Hostname dependent
  rsync "$WALLPAPER" "$STATIC" &

  sleep "$INTERVAL"m
done
