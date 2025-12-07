{
  config,
  lib,
  options,
  ...
}:
with lib; let
  cfg = config.custom.display;
in {
  options.custom.display = {
    enable = mkEnableOption "display";

    default = mkOption {
      description = "Default display output";
      default = (head (attrsToList cfg.outputs)).value; # First defined output
      example = cfg.outputs.DP-1;
      type = options.custom.display.outputs.type.nestedTypes.elemType;
    };

    forceAtBoot = mkOption {
      description = "Whether to force the mode of outputs at boot";
      default = false;
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Kernel_mode_setting#Forcing_modes_and_EDID
    # https://docs.kernel.org/fb/modedb.html
    hardware.display.outputs = let
      forcedOutputs = filterAttrs (_: o: o.force == true) cfg.outputs;
    in (mkIf cfg.forceAtBoot (mapAttrs (_: output:
      with output; {
        mode = "${toString width}x${toString height}MR@${toString refresh}";
      })
    forcedOutputs));
  };
}
