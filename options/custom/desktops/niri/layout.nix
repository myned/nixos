{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.layout;
in {
  options.custom.desktops.niri.layout = {
    enable = mkEnableOption "layout";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout
        wayland.windowManager.niri.settings.layout = {
          always-center-single-column = [];
          background-color = "#073642";
          border.active-color = "#d33682";
          border.inactive-color = "#002b36";
          border.width = config.custom.border;
          #// center-focused-column = mkIf config.custom.displays.default.ultrawide "always";
          empty-workspace-above-first = [];
          focus-ring.active-color = "#d33682";
          focus-ring.inactive-color = "#002b36";
          focus-ring.width = 0;
          gaps = config.custom.gap;
          insert-hint.color = "#d3368280";
          shadow.color = "#00000080";
          shadow.inactive-color = "#00000020";
          tab-indicator.active-color = "#d33682";
          tab-indicator.corner-radius = config.custom.rounding;
          tab-indicator.gap = config.custom.gap / 2;
          tab-indicator.gaps-between-tabs = config.custom.gap / 2;
          tab-indicator.inactive-color = "#d3368240";
          tab-indicator.length._props.total-proportion = 0.95;
          #// tab-indicator.place-within-column = [];
          tab-indicator.position = "bottom";
          tab-indicator.width = config.custom.gap / 2;

          default-column-width.proportion =
            if config.custom.displays.default.ultrawide
            then 0.3 # 30%
            else 0.6; # 60%

          preset-column-widths._children = [
            {proportion = 0.3;} # 30%, default
            {proportion = 0.4;} # 40%
            {proportion = 0.5;} # 50%
            {proportion = 0.6;} # 60%
            {proportion = 0.7;} # 70%
          ];

          preset-window-heights._children = [
            {proportion = 0.7;} # 70%
            {proportion = 0.6;} # 60%
            {proportion = 0.5;} # 50%
            {proportion = 0.4;} # 40%
            {proportion = 0.3;} # 30%
            {proportion = 1.0;} # 100%, default
          ];

          struts = let
            strut = config.custom.gap + 1;
          in {
            left = strut;
            right = strut;
            top = strut;
            bottom = strut;
          };
        };
      }
    ];
  };
}
