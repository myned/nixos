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
      gnome.enable = mkDefault (config.custom.desktop == "gnome");
      niri.enable = mkDefault (config.custom.desktop == "niri");
    };
  };
}
