#! /usr/bin/env bash

# https://gist.github.com/GrabbenD/adc5a7a863cbd1553461376cf4c50467

trap "notify-send '> vrr-fs' 󰃤" ERR

# List of supported outputs for VRR using serial number
#?? swaymsg -t get_outputs
output_vrr_whitelist=(
  "HNBW401587"
)

#  Toggle VRR for fullscreen apps in specified displays
swaymsg -t subscribe -m '[ "window" ]' | while read -r window_json; do
  window_event="$(echo "${window_json}" | jq -r '.change')"

  # Process only focus change and fullscreen toggle
  if [[ "$window_event" = "focus" || "$window_event" = "fullscreen_mode" ]]; then
    output_json="$(swaymsg -t get_outputs | jq -r '.[] | select(.focused == true)')"
    output_name="$(echo "${output_json}" | jq -r '.name')"
    output_serial="$(echo "${output_json}" | jq -r '.serial')"

    # Use only VRR in whitelisted outputs
    if [[ "${output_vrr_whitelist[*]}" =~ ${output_serial} ]]; then
      output_vrr_status="$(echo "${output_json}" | jq -r '.adaptive_sync_status')"
      window_fullscreen_status="$(echo "${window_json}" | jq -r '.container.fullscreen_mode')"

      # Only update output if necessary to avoid flickering
      [[ "$output_vrr_status" = "disabled" && "$window_fullscreen_status" = "1" ]] && swaymsg output "${output_name}" adaptive_sync 1
      [[ "$output_vrr_status" = "enabled" && "$window_fullscreen_status" = "0" ]] && swaymsg output "${output_name}" adaptive_sync 0
    fi
  fi
done
