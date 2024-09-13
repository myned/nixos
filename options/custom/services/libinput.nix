{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.libinput;
in {
  options.custom.services.libinput.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://gitlab.freedesktop.org/libinput/libinput
    services = {
      libinput.enable = true;

      # https://wiki.archlinux.org/title/Libinput#Via_Udev_Rule
      # https://wiki.archlinux.org/title/Libinput#Disable_device
      #?? libinput list-devices
      #?? udevadm info --attribute-walk /dev/input/DEVICE
      # udev.extraRules = ''
      #   # Disable controller touchpad
      #   ACTION=="add|change", ATTRS{name}=="Wireless Controller Touchpad", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      # '';
    };
  };
}
