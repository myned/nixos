#! /usr/bin/env bash

# Nix repl with loaded configuration

cd /etc/nixos || exit 1

nix run .#genflake flake.nix &&
  sleep 0.1 &&
  git add . &&
  nixos-rebuild repl "$@"
