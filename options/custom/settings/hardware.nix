{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.hardware;
in {
  options.custom.settings.hardware = {
    enable = mkEnableOption "hardware";

    cpu = mkOption {
      default = null;
      type = with types; nullOr (enum ["amd" "intel"]);
    };

    dgpu = {
      #?? lspci -k
      driver = mkOption {
        default = null;
        type = with types; nullOr str;
      };

      #?? lspci -nn
      ids = mkOption {
        default = null;
        type = with types; listOf str;
      };

      #?? ls -l /dev/dri/by-path
      node = mkOption {
        default = null;
        type = with types; nullOr str;
      };
    };

    igpu = {
      #?? lspci -k
      driver = mkOption {
        default = null;
        type = with types; nullOr str;
      };

      #?? lspci -nn
      ids = mkOption {
        default = null;
        type = with types; listOf str;
      };

      #?? ls -l /dev/dri/by-path
      node = mkOption {
        default = null;
        type = with types; nullOr str;
      };
    };

    rocm = mkOption {
      default = null;
      type = with types; nullOr str;
    };
  };

  config = mkIf cfg.enable {
    hardware =
      {
        enableAllFirmware = config.custom.default; # Non-free firmware

        # https://wiki.nixos.org/wiki/Bluetooth
        bluetooth = {
          enable = config.custom.minimal;
          package = pkgs.bluez-experimental;
        };
      }
      // optionalAttrs (cfg.dgpu.driver == "amdgpu" || cfg.igpu.driver == "amdgpu") {
        # Fix initramfs boot resolution
        #// amdgpu.initrd.enable = !(with config.custom.vms.passthrough; enable && blacklist);
      };

    nixpkgs.config =
      optionalAttrs (cfg.dgpu.driver == "nvidia" || cfg.dgpu.driver == "nouveau") {
        cudaSupport = true;
      }
      // optionalAttrs (cfg.dgpu.driver == "amdgpu") {
        rocmSupport = true;
      };
  };
}
