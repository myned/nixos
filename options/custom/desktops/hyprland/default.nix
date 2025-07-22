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
    custom = {
      desktops = mkIf config.custom.full {
        tiling = true;

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

      programs = {
        polkit.agent = true;
        uwsm.enable = true;
      };
    };

    # https://wiki.hyprland.org
    # https://github.com/hyprwm/Hyprland
    programs.hyprland = {
      enable = true;
      package = hm.wayland.windowManager.hyprland.finalPackage;

      # BUG: Some apps launched via exec cause session to end, wrap in uwsm to isolate scope
      # https://github.com/Vladimir-csp/uwsm/issues/45
      #?? uwsm app -- COMMAND
      withUWSM = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    home-manager.users.${config.custom.username} = {
      wayland.windowManager.hyprland.enable = true;

      # https://nix-community.github.io/stylix/options/modules/hyprland.html
      stylix.targets.hyprland.enable = true;
    };
  };
}
