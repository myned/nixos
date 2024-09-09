#! /usr/bin/env bash

# Screenshot region or display with rounded corners

r=20 # Radius

function round() {
  magick - \
    \( +clone -alpha extract -draw "fill black polygon 0,0 0,$r $r,0 fill white circle $r,$r $r,0" \
    \( +clone -flip \) -compose Multiply -composite \
    \( +clone -flop \) -compose Multiply -composite \) \
    -alpha off -compose CopyOpacity -composite -
}

# TODO: Use proper flags
# TODO: Add clipboard support
if [[ "${1-}" == '-e' ]]; then
  grimblast --freeze save area - | round | swappy --file -
elif [[ "${1-}" == '-d' ]]; then
  grimblast --freeze save output - | round > "$XDG_SCREENSHOTS_DIR/$(date +'%F %H.%M.%S').png"
else
  grimblast --freeze save area - | round > "$XDG_SCREENSHOTS_DIR/$(date +'%F %H.%M.%S').png"
fi
