{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops;
in {
  options.custom.desktops = {
    enable = mkEnableOption "desktops";
  };

  config = mkIf cfg.enable {
    custom.desktops = {
      gnome.enable = config.custom.desktop == "gnome";
      niri.enable = config.custom.desktop == "niri";
    };
  };
}
