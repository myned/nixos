#! /usr/bin/env bash

# @describe Wrapper for screenshot tools
#
# https://github.com/sigoden/argc
# https://github.com/hyprwm/contrib/tree/main/grimblast
# https://github.com/jtheoof/swappy

# @meta combine-shorts
# @meta inherit-flag-options
# @flag -e --edit Edit screenshot with swappy
# @flag -nc --no-copy Do not copy to clipboard after capturing
# @flag -nf --no-freeze Do not freeze display before capturing

# TODO: May not be needed for rounded corners on Hyprland
_round() {
  r=20 # Radius

  magick - \
    \( +clone -alpha extract -draw "fill black polygon 0,0 0,$r $r,0 fill white circle $r,$r $r,0" \
    \( +clone -flip \) -compose Multiply -composite \
    \( +clone -flop \) -compose Multiply -composite \) \
    -alpha off -compose CopyOpacity -composite -
}

_capture() {
  # Build arguments in array
  command=(grimblast)

  if [[ ! "${argc_no_freeze:-}" ]]; then
    command+=(--freeze)
  fi

  # Always save
  if [[ ! "${argc_no_copy:-}" ]]; then
    command+=(copysave "$1")
  else
    command+=(save "$1")
  fi

  command+=("${argc_file:-}")

  "${command[@]}"

  # Edit after first capture
  if [[ "${argc_edit:-}" ]]; then
    swappy --file "${argc_file:-}" --output-file "${argc_file_edit:-}"
  fi
}

_default_file() {
  echo "$XDG_SCREENSHOTS_DIR/$(date +'%F %H-%M-%S').png" # 1970-01-01 00-00-00.png
}

_default_file_edit() {
  echo "$XDG_SCREENSHOTS_DIR/$(date +'%F %H-%M-%S').edit.png" # 1970-01-01 00-00-00.edit.png
}

# @cmd Screenshot entire display
# @alias d,di,dis,disp,displ,displa,o,ou,out,outp,outpu,output
# @arg file=`_default_file` <FILE> File to save screenshot as, defaults to "$XDG_SCREENSHOTS_DIR/$(date +'%F %H-%M-%S').png"
# @arg file_edit=`_default_file_edit` <FILE> File to save edited screenshot as with swappy, defaults to "$XDG_SCREENSHOTS_DIR/$(date +'%F %H-%M-%S').edit.png"
display() {
  _capture output
}

# @cmd Screenshot selected area
# @meta default-subcommand
# @alias s,se,sel,sele,selec,select,selecti,selectio,a,ar,are,area
# @arg file=`_default_file` <FILE> File to save screenshot as, defaults to "$XDG_SCREENSHOTS_DIR/$(date +'%F %H-%M-%S').png"
# @arg file_edit=`_default_file_edit` <FILE> File to save edited screenshot as with swappy, defaults to "$XDG_SCREENSHOTS_DIR/$(date +'%F %H-%M-%S').edit.png"
selection() {
  _capture area
}

eval "$(argc --argc-eval "$0" "$@")"
