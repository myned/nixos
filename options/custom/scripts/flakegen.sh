#! /usr/bin/env bash

# Generate flake.nix via flakegen
# https://github.com/jorsn/flakegen

cd /etc/nixos || exit 1

if [[ "${1-}" == '-r' ]]; then
  # Nuke and reinitialize
  rm flake.nix
  nix flake init --template github:jorsn/flakegen
else
  # Generate and track all files
  nix run .#genflake flake.nix
  git add .
fi
