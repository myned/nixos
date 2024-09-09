{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.gnome-keyring;
in
{
  options.custom.services.gnome-keyring.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/GNOME/Keyring
    # https://gitlab.gnome.org/GNOME/gnome-keyring
    services.gnome-keyring.enable = true;
  };
}
