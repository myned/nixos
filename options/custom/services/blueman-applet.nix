{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.blueman-applet;
in
{
  options.custom.services.blueman-applet.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/blueman-project/blueman
    services.blueman-applet.enable = true;
  };
}
