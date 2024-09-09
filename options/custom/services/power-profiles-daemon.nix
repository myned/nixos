{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.power-profiles-daemon;
in
{
  options.custom.services.power-profiles-daemon.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://gitlab.freedesktop.org/upower/power-profiles-daemon
    #!! Usage is imperative
    #?? powerprofilesctl set <performance|balanced|power-saver>
    services.power-profiles-daemon.enable = true;
  };
}
