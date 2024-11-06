{
  config,
  lib,
  ...
}:
with lib; {
  config.custom.desktops = mkIf config.custom.full {
    hyprland.enable = true;
    sway.enable = true;
  };
}
