{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.udev;
in {
  options.custom.services.udev.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Udev
    # Allow video group to change display brightness
    # https://raw.githubusercontent.com/ErikReider/SwayOSD/main/data/udev/99-swayosd.rules
    services.udev.extraRules = let
      chgrp = "${pkgs.coreutils}/bin/chgrp";
      chmod = "${pkgs.coreutils}/bin/chmod";
    in ''
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${chgrp} video /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", RUN+="${chmod} g+w /sys/class/backlight/%k/brightness"
    '';
  };
}
