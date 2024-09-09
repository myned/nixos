#! /usr/bin/env bash

# Update flake.lock and rebuild

cd /etc/nixos || exit 1

nix run .#genflake flake.nix &&
  sleep 0.1 &&
  git add . &&
  sudo nix flake update &&
  sudo nixos-rebuild --show-trace "$@"
