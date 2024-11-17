#! /usr/bin/env bash

# @describe Wrapper for connecting to remote desktops
#
# https://github.com/sigoden/argc

# @meta combine-shorts
# @option -C --client=remmina Remote desktop client to connect with (remmina or <sdl-|x|w>freerdp)
# @option -P --password Password to connect with
# @option -S --scale=100 Set FreeRDP resolution scale
# @option -U --username! Username to connect with
# @flag -v --vm Handle libvirt VM domain state for connection
# @arg host! Remote host/VM to connect to

eval "$(argc --argc-eval "$0" "$@")"

# Handle VM state
#!! Requires libvirt networking with hostname resolution
if [[ "${argc_vm:-}" ]]; then
  state="$(virsh domstate "${argc_host:-}")"

  if [[ "$state" == "paused" ]]; then
    virsh resume "${argc_host:-}"
    notify-send "> remote" "${argc_host:-} resumed" --urgency low
  elif [[ "$state" == "shut off" ]]; then
    virsh start "${argc_host:-}"
    notify-send "> remote" "${argc_host:-} starting..." --urgency low

    # Wait for guest to become available
    #!! Requires ICMP firewall access on guest
    c=0
    while ! ping -c 1 "${argc_host:-}"; do
      if ((c > 60)); then
        notify-send "> remote" "${argc_host:-} timed out" --urgency critical
        exit 1
      fi
      ((c += 1))
      sleep 1
    done
  else
    notify-send "> remote" "${argc_host:-} online" --urgency low
  fi
fi

if [[ "${argc_client:-}" == "remmina" ]]; then
  remmina --connect "rdp://${argc_username:-}:${argc_password:-}@${argc_host:-}"
elif [[ "${argc_client:-}" =~ ^.+freerdp$ ]]; then
  export SDL_VIDEODRIVER=wayland

  flags=(
    "/cert:ignore"
    "/v:${argc_host:-}"
    "/u:${argc_username:-}"
    "/p:${argc_password:-}"
    "/kbd:remap:015b=0154" # VK_LWIN=<00> #?? xfreerdp /list:kbd-scancode
    "/scale:${argc_scale:-}"
    "/dynamic-resolution"
    "/sound"
    "+auto-reconnect"
    "+clipboard"
    "+menu-anims"
    "-grab-keyboard"
    "-grab-mouse"
  )

  "${argc_client:-}" "${flags[@]}"
fi

# Suspend VM after connection ends
if [[ "${argc_vm:-}" ]]; then
  virsh suspend "${argc_host:-}"
  notify-send "> remote" "${argc_host:-} paused" --urgency low
fi
