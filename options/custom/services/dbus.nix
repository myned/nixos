{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.services.dbus;
in
{
  options.custom.services.dbus.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/bus1/dbus-broker
    # TODO: Scour journal for dbus errors
    environment.systemPackages = with pkgs; [ dbus ];
    services.dbus.implementation = "broker"; # Newer message bus
  };
}
