{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.upower;
in
{
  options.custom.services.upower.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://gitlab.freedesktop.org/upower/upower
    services.upower.enable = true;
  };
}
