#! /usr/bin/env bash

# Enroll fingerprints
# https://wiki.archlinux.org/title/Fprint#Create_fingerprint_signature

sudo fprintd-delete root
sudo fprintd-delete "$USER"

for finger in {left,right}-{thumb,{index,middle}-finger}; do
  sudo fprintd-enroll -f "$finger" "$USER"
  sleep 2
done
