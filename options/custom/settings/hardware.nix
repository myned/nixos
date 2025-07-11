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

    cpu = mkOption {
      default = null;
      type = with types; nullOr (enum ["amd" "intel"]);
    };

    # TODO: Move top-level display vars to specific options
    display = {
      forceModesFor = mkOption {
        default = null;
        type = with types; nullOr (listOf str);
      };
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
        bluetooth.enable = config.custom.minimal;

        # https://wiki.archlinux.org/title/Kernel_mode_setting#Forcing_modes_and_EDID
        # https://docs.kernel.org/fb/modedb.html
        display.outputs = mkIf (!isNull cfg.display.forceModesFor) (listToAttrs (forEach cfg.display.forceModesFor (output: {
          name = output;
          value = with config.custom; {mode = "${toString width}x${toString height}MR@${toString refresh}";};
        })));
      }
      // optionalAttrs (with config.custom.settings.hardware; dgpu.driver == "amdgpu" || igpu.driver == "amdgpu") {
        # Fix initramfs boot resolution
        amdgpu.initrd.enable = !(with config.custom.settings.vm.passthrough; enable && blacklist);
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
