{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.gnome;
in {
  options.custom.desktops.gnome = {
    enable = mkOption {default = false;};
    auto = mkOption {default = false;};
    gdm = mkOption {default = true;};
    minimal = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/GNOME
    # FIXME: xdg-desktop-portal-[gnome|gtk] not working through steam
    services =
      {
        gnome.core-os-services.enable = cfg.minimal;

        displayManager.autoLogin = {
          enable = cfg.auto;
          user = config.custom.username;
        };
      }
      // optionalAttrs (!cfg.minimal) (
        if (versionAtLeast version "25.11")
        then {
          gnome.gnome-browser-connector.enable = true;
          desktopManager.gnome.enable = true;
          displayManager.gdm.enable = cfg.gdm;
        }
        else {
          gnome.gnome-browser-connector.enable = true;

          xserver = {
            desktopManager.gnome.enable = true;
            displayManager.gdm.enable = cfg.gdm;
          };
        }
      );
  };
}
