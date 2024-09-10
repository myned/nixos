{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.desktops.gnome;
in
{
  options.custom.desktops.gnome = {
    enable = mkOption { default = false; };
    gdm = mkOption { default = true; };
  };

  config = mkIf cfg.enable {
    # FIXME: xdg-desktop-portal-[gnome|gtk] not working through steam
    services = {
      xserver = {
        enable = true;
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = cfg.gdm;
      };

      gnome.gnome-browser-connector.enable = true; # Install extensions from browser
    };

    # Remove default packages
    # https://wiki.nixos.org/wiki/GNOME#Excluding_GNOME_Applications
    environment.gnome.excludePackages = [ pkgs.gnome-shell-extensions ];
  };
}
