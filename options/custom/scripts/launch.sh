#! /usr/bin/env bash

# @describe Wrapper for launching applications with window rules
# Relies on polling for the next open window, not the process id
# Race conditions are possible with active usage during application start
#
# https://github.com/sigoden/argc

# @meta combine-shorts
# @option -M --move Move next window to absolute position (X[%] Y[%]) (requires floating)
# @option -R --resize Resize next window to absolute dimensions (W[%] H[%]) (requires floating)
# @option -W --workspace Move next window to workspace
# @flag -a --active Focus and raise next window (raise requires floating)
# @flag -c --center Center next window (requires floating)
# @flag -f --float Float next window
# @flag -g --group Add next window to the active group
# @flag -l --lock Lock next window's group
# @flag -m --maximize Maximize next window
# @flag -n --new Add next window to a new group
# @flag -p --pin Pin next window (requires floating)
# @flag -s --fullscreen Fullscreen next window
# @flag -t --tile Tile next window
# @arg commands+ Commands to execute in an exec dispatcher

eval "$(argc --argc-eval "$0" "$@")"

# Get initial count of open windows
count="$(hyprctl -j clients | jq length)"

# Launch application
hyprctl dispatch exec "${argc_commands[@]:-}"

# Poll for next window
c=0

while (("$(hyprctl -j clients | jq length)" <= "$count")); do
  # Increment timeout counter
  ((c += 1))

  # Time out after 60 seconds
  if (("$c" >= 60 * 10)); then
    notify-send "> launch" "Polling timed out" --urgency critical
    break
  fi

  sleep 0.1
done

# Get address of last window
window="address:$(hyprctl -j clients | jq -r ".[-1].address")"

# Set batch rules on window
batch=

### Floating rules
if [[ "${argc_float:-}" ]]; then
  batch+="dispatch setfloating $window;"
fi

if [[ "${argc_center:-}" ]]; then
  batch+="dispatch focuswindow $window; dispatch centerwindow;"
fi

if [[ "${argc_move:-}" ]]; then
  batch+="dispatch movewindowpixel exact ${argc_move:-},$window;"
fi

if [[ "${argc_pin:-}" ]]; then
  batch+="dispatch pin $window;"
fi

if [[ "${argc_resize:-}" ]]; then
  batch+="dispatch resizewindowpixel exact ${argc_resize:-},$window;"
fi

### Group rules
if [[ "${argc_new:-}" ]]; then
  batch+="dispatch focuswindow $window; dispatch togglegroup;" # Requires no initial group
fi

if [[ "${argc_lock:-}" ]]; then
  batch+="dispatch focuswindow $window; dispatch lockactivegroup lock;"
fi

### Global rules
if [[ "${argc_active:-}" ]]; then
  batch+="dispatch alterzorder top,$window; dispatch focuswindow $window;" # Handles floating
fi

if [[ "${argc_fullscreen:-}" ]]; then
  batch+="dispatch focuswindow $window; dispatch fullscreen 0;"
fi

if [[ "${argc_group:-}" ]]; then
  batch+="dispatch focuswindow $window; dispatch moveintogroup up;" # Assumes up direction
fi

if [[ "${argc_maximize:-}" ]]; then
  batch+="dispatch focuswindow $window; dispatch fullscreen 1;"
fi

if [[ "${argc_tile:-}" ]]; then
  batch+="dispatch settiled $window;"
fi

if [[ "${argc_workspace:-}" ]]; then
  batch+="dispatch movetoworkspacesilent ${argc_workspace:-},$window;"
fi

# Dispatch batch commands
if [[ "${batch:-}" ]]; then
  hyprctl --batch "$batch"
fi
