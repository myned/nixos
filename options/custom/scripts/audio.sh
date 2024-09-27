#! /usr/bin/env bash

# @describe Wrapper for toggling between audio profiles
#
# https://github.com/sigoden/argc

# HACK: Condition based on file content, requires execution at login to set state
#?? exec-once = audio --init

# @meta combine-shorts
# @arg profile=Normalizer EasyEffects profile to toggle to
# @option -F --flat=`_default_flat` Flat profile to toggle from
# @option -f --file=`_default_file` Specify file for state
# @flag -b --bypass Toggle bypass instead of flat profile
# @flag -i --init Enforce state without toggling

_default_file() {
  echo "$HOME/.audio"
}

_default_flat() {
  echo Flat
}

eval "$(argc --argc-eval "$0" "$@")"

# Get current profile from file
if [[ -f "${argc_file:-}" ]]; then
  profile="$(cat "${argc_file:-}")"
else
  # Create file with flat profile if missing
  profile="${argc_flat:-}"
  echo "$profile" > "${argc_file:-}"
fi

# Toggle profile
if ! [[ "${argc_init:-}" ]]; then
  if [[ "$profile" == "${argc_profile:-}" ]]; then
    # Flat or bypass
    if [[ "${argc_bypass:-}" ]]; then
      profile=1
    else
      profile="${argc_flat:-}"
    fi
  else
    # Specified profile
    profile="${argc_profile:-}"
  fi
fi

# Enforce profile
if [[ "$profile" == 1 ]]; then
  easyeffects --bypass 1 # Enable

  if ! [[ "${argc_init:-}" ]]; then
    notify-send "> audio" "Bypass" --urgency low
  fi
else
  easyeffects --load-preset "$profile"
  easyeffects --bypass 2 # Disable

  if ! [[ "${argc_init:-}" ]]; then
    notify-send "> audio" "$profile" --urgency low
  fi
fi

# Save state
echo "$profile" > "${argc_file:-}"
