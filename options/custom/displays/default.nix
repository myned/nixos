{
  config,
  lib,
  options,
  ...
}:
with lib; let
  cfg = config.custom.displays;
in {
  options.custom.displays = {
    enable = mkEnableOption "displays";

    default = mkOption {
      description = "Default display output";
      default = (head (attrsToList cfg.outputs)).value; # First defined output
      example = cfg.outputs.DP-1;
      type = options.custom.displays.outputs.type.nestedTypes.elemType;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Kernel_mode_setting#Forcing_modes_and_EDID
    # https://docs.kernel.org/fb/modedb.html
    hardware.display.outputs = let
      forcedOutputs = filterAttrs (_: o: o.force && o.forceAtBoot) cfg.outputs;
    in (mapAttrs (_: output:
      with output; {
        mode = "${toString width}x${toString height}MR@${toString refresh}";
      })
    forcedOutputs);
  };
}
