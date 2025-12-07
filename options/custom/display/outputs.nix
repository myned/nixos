{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.display.outputs;
in {
  options.custom.display.outputs = mkOption {
    description = "Submodules of display outputs";
    default = {};

    example = {
      DP-1 = {
        name = "DP-1";
        enable = true;
        force = true;
        hdr = true;
        hidpi = true;
        minimal = true;
        ultrawide = true;
        vrr = true;
        x = 0;
        y = 0;
        width = 1920;
        height = 1080;
        refresh = 60;
        finalRefresh = 59.999;
        scale = 1;
      };
    };

    type = with types;
      attrsOf (submodule ({
        config,
        name,
        ...
      }: {
        options = {
          name = mkOption {
            description = "Name of the output";
            default = name;
            example = "DP-1";
            type = str;
          };

          enable = mkOption {
            description = "Whether to enable the output";
            default = true;
            example = false;
            type = bool;
          };

          force = mkOption {
            description = "Whether to force the mode of the output";
            default = false;
            example = true;
            type = bool;
          };

          hdr = mkOption {
            description = "Whether this output is an HDR display";
            default = false;
            example = true;
            type = bool;
          };

          hidpi = mkOption {
            description = "Whether this output is a HiDPI display";
            default = config.scale > 1;
            example = true;
            type = bool;
          };

          minimal = mkOption {
            description = "Whether this output should contain minimal interactive elements";
            default = false;
            example = true;
            type = bool;
          };

          ultrawide = mkOption {
            description = "Whether this output is an ultrawide display";
            default = config.width * 9 / 16 > config.height; # Greater than 16:9
            example = true;
            type = bool;
          };

          vrr = mkOption {
            description = "Whether to enable adaptive sync for the output";
            default = false;
            example = true;
            type = bool;
          };

          x = mkOption {
            description = "Position along the x-axis of the combined output";
            default = 0;
            example = 1920;
            type = int;
          };

          y = mkOption {
            description = "Position along the y-axis of the combined output";
            default = 0;
            example = 1080;
            type = int;
          };

          width = mkOption {
            description = "Width of the output";
            example = 1920;
            type = int;
          };

          height = mkOption {
            description = "Height of the output";
            example = 1080;
            type = int;
          };

          refresh = mkOption {
            description = "Refresh rate of the output";
            default = 60;
            example = 120;
            type = int;
          };

          finalRefresh = mkOption {
            description = "Final refresh rate of the output after forcing the mode";
            default = config.refresh + 0.0;
            example = 59.999;
            type = float;
          };

          scale = mkOption {
            description = "Scale of the output";
            default = 1.0;
            example = 1.5;
            type = float;
          };
        };
      }));
  };
}
