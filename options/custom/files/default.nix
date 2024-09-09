{ config, lib, ... }:

with lib;

{
  config.custom.files = mkIf config.custom.default {
    agenix.enable = true;
    dev.enable = true;
    mnt.enable = true;
    nixos.enable = true;
  };
}
