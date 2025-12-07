{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.output;
in {
  options.custom.desktops.niri.output = {
    enable = mkEnableOption "output";

    kanshi = mkOption {
      description = "Whether to enable kanshi for dynamic output management";
      default = true;
      example = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    custom.services.kanshi.enable = cfg.kanshi;

    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsoutputs
        #?? niri msg outputs
        programs.niri.settings.outputs = mapAttrs (_: output:
          with output;
            optionalAttrs (!cfg.kanshi) {
              inherit enable scale;

              mode = {
                inherit width height;
                refresh = finalRefresh;
              };

              position = {
                inherit x y;
              };

              variable-refresh-rate =
                if vrr
                then "on-demand" #!! Requires window-rule
                else false;
            })
        config.custom.display.outputs;
      }
    ];
  };
}
