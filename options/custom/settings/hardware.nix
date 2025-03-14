{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.hardware;
in {
  options.custom.settings.hardware = {
    enable = mkOption {default = false;};
    gpu = mkOption {default = null;};
  };

  config = mkIf cfg.enable {
    hardware = {
      enableAllFirmware = config.custom.default; # Non-free firmware

      # https://wiki.nixos.org/wiki/Bluetooth
      bluetooth.enable = config.custom.minimal;
    };

    nixpkgs.config = {
      cudaSupport = mkIf (cfg.gpu == "nvidia") true;
      rocmSupport = mkIf (cfg.gpu == "amd") true;
    };
  };
}
