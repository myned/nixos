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
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
        #?? niri msg outputs
        wayland.windowManager.niri.settings.output = let
          # BUG: Outputs not merged with includes, so avoid defining outputs for dynamic config
          staticOutputs = filterAttrs (_: o: !o.dynamic) config.custom.displays.outputs;
        in
          mkIf (attrNames staticOutputs != [])
          (mapAttrsToList (connector: output:
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
              mode._props.custom = mkIf (!forceAtBoot) force;
              position._props = {inherit x y;};
              transform =
                if transform == "0"
                then "normal"
                else if transform == "90"
                then "90"
                else if transform == "180"
                then "180"
                else if transform == "270"
                then "270"
                else if transform == "-0"
                then "flipped"
                else if transform == "-90"
                then "flipped-90"
                else if transform == "-180"
                then "flipped-180"
                else if transform == "-270"
                then "flipped-270"
                else "normal";
              variable-refresh-rate = mkIf vrr {_props.on-demand = true;}; #!! Requires window-rule
            })
          staticOutputs);
      }
    ];
  };
}
