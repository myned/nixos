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
  };

  config = mkIf cfg.enable {
    custom.desktops = {
      gnome.enable = config.custom.desktop == "gnome";
      hyprland.enable = config.custom.desktop == "hyprland";
      kde.enable = config.custom.desktop == "kde";
      niri.enable = config.custom.desktop == "niri";
      sway.enable = config.custom.desktop == "sway";
    };
  };
}
