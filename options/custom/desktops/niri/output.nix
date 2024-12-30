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
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
        programs.niri.settings.outputs = listToAttrs (forEach cfg.connectors (connector: {
          name = connector;

          value = {
            background-color = "#073642";

            mode = with config.custom; {
              inherit width height;
              refresh = refresh + 0.0; # Convert to float
            };

            scale = config.custom.scale;
          };
        }));
      }
    ];
  };
}
