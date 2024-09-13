{
  config,
  lib,
  ...
}:
with lib; {
  config.custom.desktops.hyprland.enable = config.custom.full;
}
