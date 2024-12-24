{
  config,
  lib,
  ...
}:
with lib; {
  config.custom.desktops = mkIf config.custom.full {
    #// gnome.enable = true;
    #// hyprland.enable = true;
    #// kde.enable = true;
    niri.enable = true;
    #// sway.enable = true;
  };
}
