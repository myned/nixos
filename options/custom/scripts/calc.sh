#! /usr/bin/env bash

# Dmenu qalculator
# TODO: Use --pre-display-cmd?

HISTORYFILE="$HOME/.config/qalculate/qalc.dmenu.history"

# If history file contains text
if test -s "$HISTORYFILE"; then
  # Gather unique reversed history
  prompt="$(tac "$HISTORYFILE" | nl | sort --unique --key 2 | sort | cut --fields 2)"
  lines=6
else
  # Default prompt
  prompt='Enter calculation.'
  lines=3
fi

# Prompt for calculation
input="$(wofi --dmenu --lines "$lines" <<< "$prompt")"

# Copy qalc result to history file and clipboard
result="$(qalc --terse "$input" | tee --append "$HISTORYFILE" >(xclip -rmlastnl -selection clipboard &> /dev/null) >(wl-copy --trim-newline &> /dev/null))"

notify-send '> calc' "$result" --urgency low
