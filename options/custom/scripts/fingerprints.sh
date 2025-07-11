#! /usr/bin/env bash

# Enroll fingerprints

for finger in {left,right}-{thumb,{index,middle}-finger}; do
  fprintd-enroll -f "$finger"
  sleep 2
done
