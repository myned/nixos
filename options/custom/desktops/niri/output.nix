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
    custom.displays.kanshi.enable = cfg.kanshi;

    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
        #?? niri msg outputs
        wayland.windowManager.niri.settings.output = mkIf (!cfg.kanshi) (mapAttrsToList (connector: output:
          with output; {
            _args = [connector];
            inherit scale;
            mode = "${width}x${height}@${finalRefresh}";
            position._props = {inherit x y;};
            variable-refresh-rate = mkIf vrr {_props.on-demand = true;}; #!! Requires window-rule
          })
        config.custom.displays.outputs);
      }
    ];
  };
}
