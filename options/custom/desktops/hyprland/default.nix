{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.desktops.hyprland = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    custom.desktops = mkIf config.custom.full {
      hyprland = {
        binds.enable = true;
        keywords.enable = true;
        monitors.enable = true;
        plugins.enable = true;
        rules.enable = true;
        variables.enable = true;
      };

      gnome = {
        enable = true;
        minimal = true;
      };
    };

    # https://wiki.hyprland.org
    # https://github.com/hyprwm/Hyprland
    programs.hyprland = {
      enable = true;
      package = hm.wayland.windowManager.hyprland.finalPackage;
      withUWSM = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland = {
          enable = true;
        };
      }
    ];
  };
}
