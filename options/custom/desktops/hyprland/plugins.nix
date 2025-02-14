{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland.plugins;

  hyprctl = getExe' config.programs.hyprland.package "hyprctl";
in {
  options.custom.desktops.hyprland.plugins = {
    enable = mkOption {default = false;};
    hyprbars = mkOption {default = true;};
    hyprscroller = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland = {
          # https://wiki.hyprland.org/Plugins/Using-Plugins
          plugins = with pkgs.hyprlandPlugins;
            optionals cfg.hyprbars [
              # https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars
              hyprbars
            ]
            ++ optionals cfg.hyprscroller [
              # https://github.com/dawsers/hyprscroller
              hyprscroller
            ];

          settings.plugin = {
            # https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars#config
            hyprbars = mkIf cfg.hyprbars {
              bar_button_padding = 10;
              bar_color = "rgb(002b36)";
              bar_height = 30;
              bar_padding = 10;
              bar_precedence_over_border = true; # Render borders around hyprbars
              bar_text_align = "left";
              bar_text_font = config.custom.settings.fonts.monospace;
              bar_text_size = 11;
              #// bar_title_enabled = false;
              "col.text" = "rgb(93a1a1)";

              # https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars#buttons-config
              #?? hyprbars-button = COLOR, SIZE, ICON, EXEC
              hyprbars-button = [
                "rgb(dc322f), 16,, ${hyprctl} dispatch killactive" # Close
                "rgb(d33682), 16,, ${hyprctl} dispatch fullscreen 1" # Maximize
                "rgb(6c71c4), 16,, minimize" # Minimize
              ];
            };

            # https://github.com/dawsers/hyprscroller?tab=readme-ov-file#options
            scroller = mkIf cfg.hyprscroller {
              "col.selection_border" = "rgb(d33682)";
              #// center_row_if_space_available = true;
              column_default_width = "onethird";
              #// column_widths = "onethird onehalf twothirds one";
              #// window_heights = "onethird onehalf twothirds one";
              cyclesize_wrap = false;
              focus_wrap = false;
            };
          };
        };
      }
    ];
  };
}
