#! /usr/bin/env bash

# @describe Bitwarden menu client
#
# https://github.com/sigoden/argc

# @meta combine-shorts

eval "$(argc --argc-eval "$0" "$@")"

SESSIONFILE="$XDG_RUNTIME_DIR/vault"

# Use current session if exists
if test -f "$SESSIONFILE"; then
  BW_SESSION="$(cat "$SESSIONFILE")" && export BW_SESSION
fi

# Unlock vault if needed
if ! bw unlock --check; then
  # Log in if needed
  if ! bw login --check; then
    # Prompt for server URL
    BW_SERVER="$(walker --dmenu --forceprint <<< "Logged out. Enter server URL.")"

    # Use server in bw config
    bw config server "$BW_SERVER"

    # Prompt for email and password
    BW_EMAIL="$(walker --dmenu --forceprint <<< "Saved. Enter email address.")"
    BW_PASSWORD="$(walker --dmenu --forceprint <<< "Saved. Enter master password.")"

    # Log in to vault
    BW_SESSION="$(bw login --raw "$BW_EMAIL" "$BW_PASSWORD")" && export BW_SESSION
  else
    # BUG: Walker crashes in password mode
    # Prompt for obfuscated password
    BW_PASSWORD="$(walker --dmenu --forceprint <<< "Vault locked. Enter master password.")"

    # Unlock vault
    BW_SESSION="$(bw unlock --raw "$BW_PASSWORD")" && export BW_SESSION
  fi

  # Save session to file
  touch "$SESSIONFILE"
  chmod u=rw,g=,o= "$SESSIONFILE"
  echo "$BW_SESSION" > "$SESSIONFILE"
fi

# Prompt for search term
search="$(walker --dmenu --forceprint <<< "Enter item to search.")"

# Gather and parse results
items="$(bw list items --search "$search")"
usernames="$(jq -r ".[].login.username" <<< "$items")"
passwords="$(jq -r ".[].login.password" <<< "$items")"

# Prompt to select username
username="$(walker --dmenu <<< "$usernames")"

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
tail --lines "+$count" <<< "$passwords" | head -1 | wl-copy --trim-newline &> /dev/null

notify-send "> bwm" "Copied" --urgency low
