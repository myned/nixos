#! /usr/bin/env bash

# Start/resume VM if needed and launch viewer
#?? man xfreerdp

state="$(virsh domstate myndows)"

if [[ "$state" == 'paused' ]]; then
  virsh resume myndows
  notify-send '> vm' 'Resumed' --urgency low
elif [[ "$state" == 'shut off' ]]; then
  virsh start myndows
  notify-send '> vm' 'Starting...' --urgency low

  # Wait for guest to become available
  #!! Requires ICMP firewall access on guest
  while ! ping -c 1 myndows; do
    sleep 1
  done
else
  notify-send '> vm' 'Online' --urgency low
fi

flags=(
  '/cert:ignore'
  '/v:myndows'
  '/u:Myned'
  '/p:'
  '/kbd:remap:015b=0154' # VK_LWIN=<00> #?? xfreerdp /list:kbd-scancode
  '/dynamic-resolution'
  '/sound'
  '+auto-reconnect'
  '+clipboard'
  '+menu-anims'
  '-grab-keyboard'
  '-grab-mouse'
)

if [[ "${1-}" == '-s' ]]; then
  SDL_VIDEODRIVER=wayland sdl-freerdp "${flags[@]}" "${@:2}"
  virsh suspend myndows
  notify-send '> vm' 'Paused' --urgency low
elif [[ "${1-}" == '-w' ]]; then
  wlfreerdp "${flags[@]}" "${@:2}"
  virsh suspend myndows
  notify-send '> vm' 'Paused' --urgency low
elif [[ "${1-}" == '-x' ]]; then
  xfreerdp "${flags[@]}" "${@:2}"
  virsh suspend myndows
  notify-send '> vm' 'Paused' --urgency low
elif [[ "${1-}" == '-e' ]]; then
  "$@"
  virsh suspend myndows
  notify-send '> vm' 'Paused' --urgency low
else
  "$@"
fi
