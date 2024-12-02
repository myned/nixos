{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";

  cfg = config.custom.desktops.hyprland.plugins;
in {
  options.custom.desktops.hyprland.plugins.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      # https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars
      # https://wiki.hyprland.org/Plugins/Using-Plugins
      plugins = with pkgs.hyprlandPlugins; [hyprbars];

      settings = {
        #!! Static rules
        windowrulev2 = [
          "plugin:hyprbars:bar_color rgb(073642), focus:0"
          "plugin:hyprbars:title_color rgb(586e75), focus:0"

          "plugin:hyprbars:nobar, floating:0"
          "plugin:hyprbars:nobar, class:^1Password$, title:^1Password$"
          "plugin:hyprbars:nobar, class:^clipboard$"
          "plugin:hyprbars:nobar, class:^dev\\.benz\\.walker$"
          "plugin:hyprbars:nobar, class:^discord$, title:^Discord Updater$"
          "plugin:hyprbars:nobar, class:^dropdown$"
          "plugin:hyprbars:nobar, class:^moe\\.launcher\\..+$"
          "plugin:hyprbars:nobar, class:^org\\.gnome\\.Nautilus$, title:^New Folder$"
          "plugin:hyprbars:nobar, class:^org\\.gnome\\.NautilusPreviewer$"
          "plugin:hyprbars:nobar, class:^steam$"
          "plugin:hyprbars:nobar, class:^steam_app_.+$"
          "plugin:hyprbars:nobar, class:^[Ww]aydroid.*$"
          "plugin:hyprbars:nobar, class:^Xdg-desktop-portal-gtk$"
          "plugin:hyprbars:nobar, title:^Picture.in.[Pp]icture$"
        ];

        # Plugin settings
        plugin = {
          hyprbars = {
            bar_button_padding = 10;
            bar_color = "rgb(002b36)";
            bar_height = 30;
            bar_padding = 10;
            bar_precedence_over_border = true; # Render borders around hyprbars
            bar_text_align = "left";
            bar_text_font = config.custom.font.monospace;
            bar_text_size = 11;
            #// bar_title_enabled = false;
            "col.text" = "rgb(93a1a1)";

            #?? hyprbars-button = COLOR, SIZE, ICON, EXEC
            hyprbars-button = [
              "rgb(dc322f), 16,, ${hyprctl} dispatch killactive" # Close
              "rgb(d33682), 16,, ${hyprctl} dispatch fullscreen 1" # Maximize
              "rgb(6c71c4), 16,, minimize" # Minimize
            ];
          };
        };
      };
    };
  };
}
