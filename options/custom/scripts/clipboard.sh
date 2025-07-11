#! /usr/bin/env bash

# Toggle clipboard menu

# Kill menu if running
if ! pkill wofi; then
  # Prompt clipboard for selection
  selection="$(cliphist list | wofi --dmenu)"

  # Decode and copy to clipboard
  cliphist decode <<< "$selection" | tee >(xclip -rmlastnl -selection clipboard &> /dev/null) >(wl-copy --trim-newline &> /dev/null)

  notify-send '> clipboard' 'Copied' --urgency low
fi
