{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.blueman;
in
{
  options.custom.services.blueman.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/blueman-project/blueman
    services.blueman.enable = true;
  };
}
