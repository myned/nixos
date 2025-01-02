{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.output;
in {
  options.custom.desktops.niri.output = {
    enable = mkOption {default = false;};
    connectors = mkOption {default = [];};
    disabled = mkOption {default = [];};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsoutputs
        #?? niri msg outputs
        programs.niri.settings.outputs = listToAttrs (forEach cfg.connectors (connector: {
            name = connector;

            value = {
              background-color = "#073642";

              mode = with config.custom; {
                inherit width height;
                refresh = refresh + 0.0; # Convert to float
              };

              scale = config.custom.scale;
              variable-refresh-rate = mkIf config.custom.vrr "on-demand"; #!! Requires window-rule
            };
          })
          ++ (forEach cfg.disabled (connector: {
            name = connector;
            value = {enable = false;};
          })));
      }
    ];
  };
}
