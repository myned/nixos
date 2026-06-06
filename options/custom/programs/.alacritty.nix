{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.alacritty;
in {
  options.custom.programs.alacritty = {
    enable = mkEnableOption "alacritty";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
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

        # https://nix-community.github.io/stylix/options/modules/alacritty.html
        stylix.targets.alacritty.enable = true;
      }
    ];
  };
}
