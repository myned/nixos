#! /usr/bin/env bash

# @describe Wrapper for switching between window geometries
#
# https://github.com/sigoden/argc

# @meta combine-shorts

_default_file() {
  echo "/tmp/window.move"
}

# @cmd Move window to and from specified location, requires floating
# @alias m,mo,mov
# @arg window! Window to switch, in regex
# @arg to*, X,Y position to move to
# @arg from*, X,Y position to move from
# @option -f --file=`_default_file` File to save current window position
# @option -p --property=class Property to match window, such as class or title
# @flag -c --current Use current window position to move from
move() {
  window="${argc_property:-}:${argc_window:-}"

  # Get current position
  position="$(hyprctl -j clients | jq -r ".[] | select(.${argc_property:-} | test(\"${argc_window:-}\")).at")" # [X,Y]

  if [[ "${argc_current:-}" ]]; then
    if [[ -f "${argc_file:-}" ]]; then
      # Pop saved position
      argc_from[0]="$(jq ".[0]" "${argc_file:-}")"
      argc_from[1]="$(jq ".[1]" "${argc_file:-}")"
      rm --force "${argc_file:-}"
    else
      # Save current position
      echo "$position" > "${argc_file:-}"
    fi
  fi

  # Switch between specified positions
  if [[ "$(echo "$position" | jq .[0])" == "${argc_to[0]:-}" ]] && [[ "$(echo "$position" | jq .[1])" == "${argc_to[1]:-}" ]]; then
    hyprctl dispatch movewindowpixel exact "${argc_from[0]:-}" "${argc_from[1]:-}","$window"
  else
    hyprctl dispatch movewindowpixel exact "${argc_to[0]:-}" "${argc_to[1]:-}","$window"
  fi
}

eval "$(argc --argc-eval "$0" "$@")"
