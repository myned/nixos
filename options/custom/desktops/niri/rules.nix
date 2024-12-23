{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.rules;
in {
  options.custom.desktops.niri.rules = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
      programs.niri.settings.window-rules = [
        {
          geometry-corner-radius = let
            radius = config.custom.rounding + 0.0; # Convert to float
          in {
            top-left = radius;
            top-right = radius;
            bottom-right = radius;
            bottom-left = radius;
          };

          clip-to-geometry = true;
        }
      ];
    };
  };
}
