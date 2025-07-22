{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.kitty;
in {
  options.custom.programs.kitty = {
    enable = mkEnableOption "kitty";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://sw.kovidgoyal.net/kitty/
      # https://github.com/kovidgoyal/kitty
      programs.kitty = {
        enable = true;
        shellIntegration.mode = "no-cursor"; # Disable forced beam cursor

        # https://sw.kovidgoyal.net/kitty/conf/
        #?? man kitty
        settings = {
          active_tab_font_style = "bold";
          inactive_tab_font_style = "normal";
          confirm_os_window_close = 0;
          cursor_blink_interval = 0;
          cursor_shape = "block";
          cursor_shape_unfocused = "hollow";
          placement_strategy = "top-left"; # Partially fix padding
          scrollback_lines = -1;
          strip_trailing_spaces = "smart";
          tab_bar_style = "powerline";
          touch_scroll_multiplier = 5;
          url_style = "straight";
          wayland_enable_ime = "no";
          window_padding_width = "2.5 5"; # top/bottom left/right

          # Solarized Dark colors
          # https://ethanschoonover.com/solarized/
          #?? kitten themes
          cursor = "none"; # Inherit text tcolor
          background = "#002b36";
          foreground = "#839496";
          active_tab_background = "#93a1a1";
          active_tab_foreground = "#002b36";
          inactive_tab_background = "#586e75";
          inactive_tab_foreground = "#002b36";
          selection_background = "#586e75"; # Affects scrollbar color
          selection_foreground = "#002b36";
          url_color = "#586e75";

          color0 = "#073642";
          color1 = "#dc322f";
          color2 = "#859900";
          color3 = "#b58900";
          color4 = "#268bd2";
          color5 = "#d33682";
          color6 = "#2aa198";
          color7 = "#eee8d5";
          color8 = "#002b36";
          color9 = "#cb4b16";
          color10 = "#586e75";
          color11 = "#657b83";
          color12 = "#839496";
          color13 = "#6c71c4";
          color14 = "#93a1a1";
          color15 = "#fdf6e3";
        };
      };

      # https://nix-community.github.io/stylix/options/modules/kitty.html
      stylix.targets.kitty.enable = false;
    };
  };
}
