{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.hardware;
in {
  options.custom.settings.hardware = {
    enable = mkEnableOption "hardware";

    gpu = mkOption {
      default = null;
      type = with types; nullOr str;
    };

    igpu = mkOption {
      default = false;
      type = types.bool;
    };

    rocm = mkOption {
      default = null;
      type = with types; nullOr str;
    };
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
