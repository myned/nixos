#! /usr/bin/env bash

# Bitwarden dmenu
# TODO: Clear clipboard after timer

SESSIONFILE="$XDG_RUNTIME_DIR/bwm"

# Use current session if exists
if test -f "$SESSIONFILE"; then
  BW_SESSION="$(cat "$SESSIONFILE")" && export BW_SESSION
fi

# Unlock vault if needed
if ! bw unlock --check; then
  # Prompt for obfuscated password
  password="$(wofi --dmenu --password --lines 3 <<< 'Vault locked. Enter master password.')"

  # Save session to /tmp
  BW_SESSION="$(bw unlock "$password" --raw)" && export BW_SESSION
  touch "$SESSIONFILE"
  chmod u=rw,g=,o= "$SESSIONFILE"
  echo "$BW_SESSION" > "$SESSIONFILE"
fi

# Prompt for search term
search="$(wofi --dmenu --lines 3 <<< 'Enter item to search.')"

# Gather and parse results
items="$(bw list items --search "$search")"
usernames="$(jq -r '.[].login.username' <<< "$items")"
passwords="$(jq -r '.[].login.password' <<< "$items")"

# Prompt to select username
username="$(wofi --dmenu <<< "$usernames")"

# Find matching password line number
count=1

while IFS= read -r username; do
  if [[ "$username" == "$username" ]]; then
    break
  else
    ((count++))
  fi
done <<< "$usernames"

# Copy line to clipboard
tail --lines "+$count" <<< "$passwords" | head -1 | tee >(xclip -rmlastnl -selection clipboard &> /dev/null) >(wl-copy --trim-newline &> /dev/null)

notify-send '> bwm' 'Copied' --urgency low
