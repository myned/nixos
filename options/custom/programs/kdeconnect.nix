{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.kdeconnect;
in
{
  options.custom.programs.kdeconnect.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/KDE/kdeconnect-kde
    programs.kdeconnect.enable = true;
  };
}
