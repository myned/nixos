#! /usr/bin/env bash

# Rebuild local flake configuration

cd /etc/nixos || exit 1

nix run .#genflake flake.nix &&
  sleep 0.1 &&
  git add . &&
  sudo nixos-rebuild --show-trace "$@"
