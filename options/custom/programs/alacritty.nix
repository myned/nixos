{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.alacritty;
in
{
  options.custom.programs.alacritty.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/alacritty/alacritty
    programs.alacritty = {
      enable = true;

      # https://alacritty.org/config-alacritty.html
      settings = {
        font = {
          #// builtin_box_drawing = false;
          size = 14;
        };

        window = {
          dynamic_padding = true;
          resize_increments = true;
        };
      };
    };
  };
}
