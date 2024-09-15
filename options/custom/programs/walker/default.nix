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

      # https://github.com/abenz1267/walker/wiki/Basic-Configuration
      # https://github.com/abenz1267/walker/blob/master/internal/config/config.default.json
      config = {
        activation_mode.disabled = true; # Key chords
        ignore_mouse = true; # Hover interrupts keyboard selections
        search.placeholder = "";

        # https://github.com/abenz1267/walker/wiki/Modules
        # https://www.nerdfonts.com/cheat-sheet
        builtins = {
          calculator.switcher_only = false;
          clipboard.switcher_only = true;
          commands.switcher_only = true;
          custom_commands.switcher_only = true;
          runner.switcher_only = true;
          ssh.switcher_only = true;
          windows.switcher_only = true;

          applications = {
            # BUG: Ghost entries are still visible
            #// actions = false; # Desktop file actions

            switcher_only = false;
            weight = 10;
          };

          dmenu = {
            keep_sort = true; # Disable sorting entries
            placeholder = "Input";
            switcher_only = true;
          };

          emojis = {
            placeholder = "Unicode";
            switcher_only = false;
          };

          finder = {
            placeholder = "Files";
            switcher_only = true;
          };

          websearch = {
            placeholder = "Search";
            switcher_only = true;
          };
        };
      };

      # https://github.com/abenz1267/walker/wiki/Theming
      theme = {
        style = builtins.readFile ./style.css;

        # https://github.com/abenz1267/walker/blob/master/internal/config/layout.default.json
        layout.ui.window.box = rec {
          height = 250 / config.custom.scale;
          width = 1000 / config.custom.scale;

          scroll.list = {
            max_height = height;
            max_width = width;
            min_width = width;

            # Icon resolution
            item = {
              text.sub.hide = true; # Subtext

              icon = {
                icon_size = "largest"; # 128px
                pixel_size = 32; # Downscale
              };
            };
          };
        };
      };
    };
  };
}
