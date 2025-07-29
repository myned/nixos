{
  config,
  lib,
  pkgs,
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
      // optionalAttrs (!cfg.minimal) ({
          gnome.gnome-browser-connector.enable = true;
        }
        // (
          if (versionAtLeast version "25.11")
          then {
            desktopManager.gnome.enable = true;
            displayManager.gdm.enable = cfg.gdm;
          }
          else {
            xserver = {
              desktopManager.gnome.enable = true;
              displayManager.gdm.enable = cfg.gdm;
            };
          }
        ));

    # https://github.com/mjakeman/extension-manager
    environment.systemPackages = optionals (!cfg.minimal) [pkgs.gnome-extension-manager];

    # https://nix-community.github.io/stylix/options/modules/gnome.html
    stylix.targets.gnome.enable = true;

    home-manager.users.${config.custom.username} = {
      stylix.targets.gnome.enable = true;
    };
  };
}
