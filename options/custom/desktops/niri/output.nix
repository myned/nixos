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
      default = false;
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
            inherit scale;
            _args = [
              (
                if model != null
                then model
                else connector
              )
            ];
            layout.default-column-width.proportion =
              if ultrawide
              then 0.3 # 30%
              else 0.6; # 60%
            mode._args = ["${toString width}x${toString height}@${toString finalRefresh}"];
            mode._props.custom = force;
            position._props = {inherit x y;};
            variable-refresh-rate = mkIf vrr {_props.on-demand = true;}; #!! Requires window-rule
          })
        config.custom.displays.outputs);
      }
    ];
  };
}
