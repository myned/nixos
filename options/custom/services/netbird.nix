{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.netbird;
in
{
  options.custom.services.netbird.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/netbirdio/netbird
    services.netbird = {
      enable = true;
    };
  };
}
