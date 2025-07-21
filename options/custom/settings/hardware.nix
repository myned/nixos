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

    display = {
      # TODO: Parse over outputs instead of using separate option
      forceModes = mkOption {
        default = false;
        type = types.bool;
      };

      # TODO: Use submodule type
      outputs = mkOption {
        default = [];
        description = "List of output attrsets";
        type = types.attrs;

        example = [
          {
            DP-1 = {
              width = 1920;
              height = 1080;
              refresh = 60;
              force = true;
              vrr = true;

              position = {
                x = 0;
                y = 0;
              };
            };
          }
        ];
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
        display.outputs = mkIf cfg.display.forceModes (mapAttrs (name: value: {
            mode = with value; "${toString width}x${toString height}MR@${toString refresh}";
          })
          cfg.display.outputs);
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
