{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.openrazer;
in {
  options.custom.services.openrazer = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Hardware/Razer
    # https://openrazer.github.io/
    # https://github.com/openrazer/openrazer
    hardware.openrazer = {
      enable = true;
      users = [config.custom.username];

      batteryNotifier = {
        enable = true;
        frequency = 60 * 60; # Seconds
        percentage = 15;
      };
    };

    # https://polychromatic.app/
    environment.systemPackages = [pkgs.polychromatic];
  };
}
