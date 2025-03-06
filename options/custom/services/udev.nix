{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.udev;

  chgrp = getExe' pkgs.coreutils "chgrp";
  chmod = getExe' pkgs.coreutils "chmod";
in {
  options.custom.services.udev = {
    enable = mkOption {default = false;};
    backlight = mkOption {default = true;};
    input = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Udev
    services.udev.extraRules =
      optionalString cfg.backlight ''
        # Allow video group to change display brightness
        # https://raw.githubusercontent.com/ErikReider/SwayOSD/main/data/udev/99-swayosd.rules
        ACTION=="add", \
          SUBSYSTEM=="backlight", \
          RUN+="${chgrp} video /sys/class/backlight/%k/brightness"
        ACTION=="add", \
          SUBSYSTEM=="backlight", \
          RUN+="${chmod} g+w /sys/class/backlight/%k/brightness"
      ''
      + optionalString cfg.input ''
        # Per-device input configuration
        # https://wiki.archlinux.org/title/Libinput#Via_Udev_Rule
        # https://wayland.freedesktop.org/libinput/doc/latest/device-configuration-via-udev.html
        #?? sudo libinput list-devices
        #?? sudo udevadm info /dev/input/event*
        #?? sudo udevadm trigger /dev/input/event*

        # Kensington Orbit
        ENV{ID_USB_SERIAL}=="Kensington_ORBIT_WIRELESS_TB", \
          ENV{ID_INPUT_MOUSE}="", \
          ENV{ID_INPUT_TRACKBALL}="1"

        # ProtoArc EM04
        ENV{ID_USB_SERIAL}=="Nordic_2.4G_Wireless_Receiver", \
          ENV{ID_INPUT_MOUSE}="", \
          ENV{ID_INPUT_TRACKBALL}="1"
      '';
  };
}
