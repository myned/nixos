#! /usr/bin/env bash

# Enroll fingerprints
# https://wiki.archlinux.org/title/Fprint#Create_fingerprint_signature

for finger in {left,right}-{thumb,{index,middle}-finger}; do
  sudo fprintd-delete root
  sudo fprintd-delete "$USER"
  sudo fprintd-enroll -f "$finger" "$USER"
  sleep 2
done
