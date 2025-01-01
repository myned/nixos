{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.wezterm;
in {
  options.custom.programs.wezterm.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/wez/wezterm
    programs.wezterm = {
      enable = true;

      # https://wezfurlong.org/wezterm/config/files.html
      extraConfig = ''
        -- Provided by module
        -- local wezterm = require 'wezterm'

        local act = wezterm.action
        local config = wezterm.config_builder()

        config.font = wezterm.font('${config.custom.settings.fonts.monospace}')

        -- # TODO: Remove when using Wayland
        config.font_size = ${toString (14 * config.custom.scale)}

        ${readFile ./config.lua}

        return config
      '';

      # https://wezfurlong.org/wezterm/config/appearance.html#defining-a-color-scheme-in-a-separate-file
      colorSchemes.solarized = {
        background = "#002b36";
        foreground = "#839496";
        selection_bg = "#839496";
        selection_fg = "#073642";
        cursor_border = "#839496";
        scrollbar_thumb = "#073642";

        ansi = [
          "073642"
          "dc322f"
          "859900"
          "b58900"
          "268bd2"
          "d33682"
          "2aa198"
          "eee8d5"
        ];

        brights = [
          "002b36"
          "cb4b16"
          "586e75"
          "657b83"
          "839496"
          "6c71c4"
          "93a1a1"
          "fdf6e3"
        ];
      };
    };
  };
}
