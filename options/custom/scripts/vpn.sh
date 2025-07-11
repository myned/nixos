#! /usr/bin/env bash

# Toggle tailscale exit node

if [[ "$(tailscale status --json | jq .ExitNodeStatus.Online)" == 'true' ]]; then
  sudo tailscale set --exit-node=
  notify-send '> vpn' 'Disconnected' --urgency low
elif [[ "${1-}" == '-s' ]]; then
  # TODO: Remove regex workaround when tailscale v1.70.0 is in nixpkgs
  suggested="$(tailscale exit-node suggest | sed --regexp-extended --quiet 's/Suggested exit node: (.+)\./\1/p')"
  sudo tailscale set --exit-node="$suggested" --exit-node-allow-lan-access
  notify-send '> vpn' "Connected to $suggested" --urgency low
else
  sudo tailscale set --exit-node="$1" --exit-node-allow-lan-access
  notify-send '> vpn' "Connected to $1" --urgency low
fi
