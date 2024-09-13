{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.hardware;
in {
  options.custom.settings.hardware.enable = mkOption {default = false;};

  config.hardware = mkIf cfg.enable {
    enableAllFirmware = config.custom.default; # Non-free firmware

    # https://wiki.nixos.org/wiki/Bluetooth
    bluetooth.enable = config.custom.minimal;
  };
}
