{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops;
in {
  options.custom.desktops = {
    enable = mkOption {default = config.custom.minimal;};

    desktop = mkOption {
      default =
        if config.custom.full
        then "niri"
        else "gnome";
    };
  };

  config = mkIf cfg.enable {
    custom.desktops = {
      gnome.enable = cfg.desktop == "gnome";
      hyprland.enable = cfg.desktop == "hyprland";
      kde.enable = cfg.desktop == "kde";
      niri.enable = cfg.desktop == "niri";
      sway.enable = cfg.desktop == "sway";
    };
  };
}
