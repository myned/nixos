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
        gaps = gap;
        center-focused-column = mkIf config.custom.ultrawide "always";
        always-center-single-column = true;

        # TODO: Uncomment after next release > v1.10.1
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout#empty-workspace-above-first
        #// empty-workspace-above-first = true;

        preset-column-widths = [
          {proportion = 0.5;}
          {proportion = 0.3;}
          {proportion = 0.7;} # Default
        ];

        default-column-width = {proportion = 0.7;};

        preset-window-heights = [
          {proportion = 0.7;}
          {proportion = 0.5;}
          {proportion = 0.3;}
          {proportion = 1.0;} # Default
        ];

        border = {
          enable = true;
          width = config.custom.border;
          active.color = "#d33682";
          inactive.color = "#00000000";
        };

        focus-ring.enable = false;

        insert-hint = {
          enable = true;
          display.color = "#d3368280";
        };

        struts = {
          left = gap;
          right = gap;
          top = gap;
          bottom = gap;
        };
      };
    };
  };
}
