{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.kdeconnect;
in
{
  options.custom.services.kdeconnect.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/KDE/kdeconnect-kde
    services.kdeconnect.enable = true;
  };
}
