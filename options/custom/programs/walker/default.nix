{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.walker;
in {
  options.custom.programs.walker.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    imports = [inputs.walker.homeManagerModules.default];

    # https://github.com/abenz1267/walker
    # https://github.com/abenz1267/walker?tab=readme-ov-file#building-from-source
    # https://github.com/abenz1267/walker/blob/master/nix/hm-module.nix
    programs.walker = {
      enable = true;
      package = pkgs.walker;

      #!! Service must be restarted for changes to take effect
      #?? systemctl --user restart walker.service
      runAsService = true;

      # https://github.com/abenz1267/walker/blob/master/internal/config/config.default.json
      config = {
        activation_mode.labels = ""; # Chord indicators
        search.placeholder = "";

        builtins = {
          applications = {
            actions = false; # Desktop file actions
            prioritize_new = false;
            show_sub_when_single = false; # Subtext with one module
          };
        };
      };

      # https://github.com/abenz1267/walker/wiki/Theming
      theme = {
        style = builtins.readFile ./style.css;

        # https://github.com/abenz1267/walker/blob/master/internal/config/themes/bare.json
        layout.ui.window.box = rec {
          height = 500 / config.custom.scale;
          width = 1000 / config.custom.scale;

          scroll.list = {
            min_height = height;
            max_height = height;
            max_width = width;
            min_width = width;

            # Icon resolution
            item.icon = {
              icon_size = "largest"; # 128px
              pixel_size = 32;
            };
          };
        };
      };
    };
  };
}
