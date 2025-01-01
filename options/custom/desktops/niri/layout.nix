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
          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutalways-center-single-column
          always-center-single-column = true;

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutborder
          border = {
            enable = true;
            width = config.custom.border;
            active.color = "#d33682";
            inactive.color = "#00000000";
          };

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutcenter-focused-column
          #// center-focused-column = mkIf config.custom.ultrawide "always";

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutdefault-column-width
          default-column-width.proportion = 1.0 / 3.0; # 33%

          # TODO: Uncomment after next release > v1.10.1
          #// empty-workspace-above-first = true;

          focus-ring.enable = false;
          gaps = gap;

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutinsert-hint
          insert-hint = {
            enable = true;
            display.color = "#d3368280";
          };

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutpreset-column-widths
          preset-column-widths = [
            {proportion = 1.0 / 3.0;} # 33%, default
            {proportion = 2.0 / 3.0;} # 66%
            {proportion = 3.0 / 3.0;} # 100%
          ];

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutpreset-window-heights
          preset-window-heights = [
            {proportion = 2.0 / 3.0;} # 66%
            {proportion = 1.0 / 3.0;} # 33%
            {proportion = 3.0 / 3.0;} # 100%, default
          ];

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutstruts
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
