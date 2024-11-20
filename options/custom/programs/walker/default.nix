{
  config,
  lib,
  inputs,
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

      #!! Service must be restarted for changes to take effect
      #?? systemctl --user restart walker.service
      runAsService = true;

      # https://github.com/abenz1267/walker/wiki/Basic-Configuration
      # https://github.com/abenz1267/walker/blob/master/internal/config/config.default.json
      config = {
        activation_mode.disabled = true; # Key chords

        # BUG: Hover interrupts keyboard selections
        ignore_mouse = true;

        search.placeholder = "";

        disabled = [
          # BUG: Applications such as GNOME Files require multiple copy operations to register
          "clipboard"
        ];

        # https://github.com/abenz1267/walker/wiki/Modules
        # https://www.nerdfonts.com/cheat-sheet
        builtins = {
          clipboard.switcher_only = true;
          commands.switcher_only = true;
          custom_commands.switcher_only = true;
          runner.switcher_only = true;
          ssh.switcher_only = true;
          windows.switcher_only = true;

          applications = {
            # BUG: Ghost entries are still visible with single module
            actions = false; # Desktop file actions

            switcher_only = false;
          };

          calc = {
            min_chars = 0;
            switcher_only = true;
          };

          dmenu = {
            keep_sort = true; # Disable sorting entries
            placeholder = "Input";
            switcher_only = true;
          };

          emojis = {
            placeholder = "Unicode";
            switcher_only = true;
          };

          finder = {
            placeholder = "Files";
            switcher_only = true;
          };

          websearch = {
            # TODO: Implement custom search engine
            engines = ["duckduckgo"];

            placeholder = "Search";
            switcher_only = true;
          };
        };
      };

      # https://github.com/abenz1267/walker/wiki/Theming
      theme = {
        style = ''
          #box {
            font: larger ${config.custom.font.sans-serif};
          }

          ${builtins.readFile ./style.css}
        '';

        # https://github.com/abenz1267/walker/blob/master/internal/config/layout.default.json
        layout.ui.window.box.scroll.list = {
          max_height = 500 / config.custom.scale;
          min_width = 750 / config.custom.scale;

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

    # HACK: Allow child processes to live, otherwise applications launched through service are killed on stop
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.kill.html#KillMode=
    systemd.user.services.walker.Service.KillMode = "process";
  };
}
