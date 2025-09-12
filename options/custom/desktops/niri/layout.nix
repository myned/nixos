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
    home-manager.users.${config.custom.username} = {
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
          inactive.color = "#073642";
        };

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutcenter-focused-column
        #// center-focused-column = mkIf config.custom.ultrawide "always";

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutdefault-column-width
        default-column-width.proportion =
          if config.custom.ultrawide
          then 0.3 # 30%
          else 0.6; # 60%

        empty-workspace-above-first = true;

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutfocus-ring
        focus-ring = {
          enable = false;
          width = config.custom.border;
          active.color = "#d33682";
          inactive.color = "#073642";
        };

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutgaps
        gaps = gap;

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutinsert-hint
        insert-hint = {
          enable = true;
          display.color = "#d3368280";
        };

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutpreset-column-widths
        preset-column-widths = [
          {proportion = 0.3;} # 30%, default
          {proportion = 0.4;} # 40%
          {proportion = 0.5;} # 50%
          {proportion = 0.6;} # 60%
          {proportion = 0.7;} # 70%
        ];

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutpreset-window-heights
        preset-window-heights = [
          {proportion = 0.7;} # 70%
          {proportion = 0.6;} # 60%
          {proportion = 0.5;} # 50%
          {proportion = 0.4;} # 40%
          {proportion = 0.3;} # 30%
          {proportion = 1.0;} # 100%, default
        ];

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutshadowcolor
        shadow = {
          color = "#00000080";
          inactive-color = "#00000020";
        };

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayoutstruts
        struts = let
          strut = gap;
        in {
          left = strut;
          right = strut;
          top = strut;
          bottom = strut;
        };

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingslayouttab-indicator
        tab-indicator = {
          corner-radius = config.custom.rounding;
          gap = 2;
          gaps-between-tabs = 2;
          active.color = "#d33682";
          inactive.color = "#d3368240";
          length.total-proportion = 0.95;
          place-within-column = true;
          width = config.custom.border + 3;
        };
      };
    };
  };
}
