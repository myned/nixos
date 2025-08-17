{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.gdm;
in {
  options.custom.services.gdm = {
    enable = mkEnableOption "gdm";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/GNOME
    # https://wiki.archlinux.org/title/GDM
    services =
      if (versionAtLeast version "25.11")
      then {
        displayManager.gdm = {
          enable = true;
        };
      }
      else {
        xserver.displayManager.gdm = {
          enable = true;
        };
      };
  };
}
