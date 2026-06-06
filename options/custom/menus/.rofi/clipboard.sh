#! /usr/bin/env bash

TMPDIR=/tmp/cliphist

# Clean up tmp dir
rm -rf "$TMPDIR"

# TODO: Add keybinds
# https://github.com/lbonn/rofi/blob/wayland/doc/rofi-script.5.markdown#environment
case "$ROFI_RETV" in
  # List entries
  0)
    mkdir -p "$TMPDIR"

    # Parse over clipboard
    cliphist list | while read -r line; do
      # Skip over HTML elements
      # https://github.com/sentriz/cliphist/commit/95c193604fce7c5ec094ff9bf1c62cc6f5395750
      if [[ "$line" == *meta\ http-equiv=* ]]; then
        continue
      fi

      # Isolate index and entry name
      id="$(cut -f 1 - <<< "$line")"
      name="$(cut -f 2 - <<< "$line")"

      # Check for image entries
      if [[ "$line" =~ ^([0-9]+)[[:space:]]+\[\[\ binary.*(jpg|jpeg|png|bmp) ]]; then
        # Set image extension and icon path
        extension="${BASH_REMATCH[2]}"
        icon="$TMPDIR/$id.$extension"

        # Write decoded image to tmp dir
        if ! [[ -f "$icon" ]]; then
          cliphist decode "$id" > "$icon"
        fi

        # Pass entry to rofi
        printf '%s\x0icon\x1f%s\x1finfo\x1f%s\n' "$name" "$icon" "$id"
      else
        printf '%s\x0info\x1f%s\n' "$name" "$id"
      fi
    done
    ;;
  # Select entry
  1)
    # Decode from env var and copy to clipboard
    cliphist decode "$ROFI_INFO" | wl-copy
    ;;
esac
