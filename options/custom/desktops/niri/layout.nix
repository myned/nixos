{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.layout;
in {
  options.custom.desktops.niri.layout = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout
        programs.niri.settings.layout = let
          gap = config.custom.gap / 2;
        in {
          always-center-single-column = true;

          border = {
            enable = true;
            width = config.custom.border;
            active.color = "#d33682";
            inactive.color = "#00000000";
          };

          #/// center-focused-column = mkIf config.custom.ultrawide "always";
          default-column-width.proportion = 1.0 / 3.0; # 33%

          # TODO: Uncomment after next release > v1.10.1
          # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout#empty-workspace-above-first
          #// empty-workspace-above-first = true;

          focus-ring.enable = false;
          gaps = gap;

          insert-hint = {
            enable = true;
            display.color = "#d3368280";
          };

          preset-column-widths = [
            {proportion = 1.0 / 3.0;} # 33%, default
            {proportion = 2.0 / 3.0;} # 66%
            {proportion = 3.0 / 3.0;} # 100%
          ];

          preset-window-heights = [
            {proportion = 2.0 / 3.0;} # 66%
            {proportion = 1.0 / 3.0;} # 33%
            {proportion = 3.0 / 3.0;} # 100%, default
          ];

          struts = {
            left = gap;
            right = gap;
            top = gap;
            bottom = gap;
          };
        };
      }
    ];
  };
}
