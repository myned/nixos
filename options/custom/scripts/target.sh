#! /usr/bin/env bash

# Rebuild and send closures to remote machine

cd /etc/nixos || exit 1

nix run .#genflake flake.nix &&
  sleep 0.1 &&
  git add . &&
  nixos-rebuild --flake .#"$1" --target-host root@"$1" "$2" --show-trace "${@:3}"
