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

    # TODO: Use submodule type
    outputs = mkOption {
      default = {};
      description = "Attrset of output submodules";
      type = types.attrs;

      example = {
        DP-1 = {
          x = 0;
          y = 0;
          width = 1920;
          height = 1080;
          refresh = 60;
          scale = 1;
          vrr = true;
          force = true;
        };
      };
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
        display.outputs = let
          forcedOutputs = filterAttrs (name: value: value.force == true) cfg.outputs;
        in (mapAttrs (name: value: {
            mode = with value; "${toString width}x${toString height}MR@${toString refresh}";
          })
          forcedOutputs);
      }
      // optionalAttrs (cfg.dgpu.driver == "amdgpu" || cfg.igpu.driver == "amdgpu") {
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
