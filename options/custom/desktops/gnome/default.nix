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
    enable = mkEnableOption "gnome";

    autoLogin = mkOption {
      default = false;
      description = "Whether to log in automatically";
      example = true;
      type = types.bool;
    };

    minimal = mkOption {
      default = false;
      description = "Whether to enable the minimum amount of GNOME services";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/GNOME
    # FIXME: xdg-desktop-portal-[gnome|gtk] not working through steam
    services = {
      # Minimal installation
      gnome = mkIf cfg.minimal {
        core-os-services.enable = true;
      };

      displayManager.autoLogin = {
        enable = cfg.autoLogin;
        user = config.custom.username;
      };

      ${
        if versionAtLeast version "25.11"
        then "desktopManager"
        else "xserver.desktopManager"
      }.gnome.enable =
        !cfg.minimal;
    };

    # https://github.com/mjakeman/extension-manager
    environment.systemPackages = optionals (!cfg.minimal) [pkgs.gnome-extension-manager];

    # https://nix-community.github.io/stylix/options/modules/gnome.html
    stylix.targets.gnome.enable = true;

    home-manager.sharedModules = [
      {
        stylix.targets.gnome.enable = true;
      }
    ];
  };
}
