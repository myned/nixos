{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland;
in {
  options.custom.desktops.hyprland.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    custom.desktops.hyprland = mkIf config.custom.full {
      binds.enable = true;
      plugins.enable = true;
      rules.enable = true;
      settings.enable = true;
    };

    # https://github.com/hyprwm/Hyprland
    programs.hyprland.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];

      # Prefer hyprland over gtk portal
      config.common.default = [
        "hyprland"
        "gtk"
      ];
    };

    # https://wiki.hyprland.org
    home-manager.users.${config.custom.username}.wayland.windowManager.hyprland = {
      enable = true;
      systemd.variables = ["--all"]; # Import some environment variables into session
    };
  };
}
