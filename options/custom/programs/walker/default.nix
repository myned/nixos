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

      #!! Service must be restarted for changes to take effect
      #?? systemctl --user restart walker.service
      runAsService = true;

      # https://github.com/abenz1267/walker/wiki/Basic-Configuration
      # https://github.com/abenz1267/walker/blob/master/internal/config/config.default.json
      config = {
        activation_mode.disabled = true; # Key chords
        force_keyboard_focus = true;
        list.placeholder = "";
        search.placeholder = "";

        # HACK: Window client required to send Esc key on Hyprland
        #// as_window = true; # Disable layer

        # https://github.com/abenz1267/walker/wiki/Modules
        # https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/tree/master/Papirus/64x64
        disabled = [
          "commands"
          "custom_commands"
          "websearch" # Replaced by custom plugin
          "windows"
        ];

        builtins = {
          applications = {
            # BUG: Ghost entries are still visible with single module
            actions.enabled = false;
            hide_actions_with_empty_query = true;

            placeholder = "";
            switcher_only = false;
          };

          calc = {
            icon = "accessories-calculator";
            min_chars = 1;
            placeholder = "";
            prefix = "=";
            show_icon_when_single = true;
            switcher_only = false;
          };

          clipboard = {
            max_entries = 50;
            placeholder = "";
            switcher_only = true;
          };

          dmenu = {
            keep_sort = true;
            placeholder = "";
            switcher_only = true;
          };

          emojis = {
            placeholder = "";
            prefix = "`";
            switcher_only = false;
          };

          finder = {
            icon = "filetypes";
            placeholder = "";
            prefix = "/";
            show_icon_when_single = true;
            switcher_only = false;
          };

          runner = {
            icon = "utilities-x-terminal";
            placeholder = "";
            prefix = ">";
            show_icon_when_single = true;
            switcher_only = false;
          };

          ssh = {
            icon = "folder-remote-symbolic";
            placeholder = "";
            prefix = "ssh";
            show_icon_when_single = true;
            switcher_only = false;
          };

          switcher = {
            icon = "application-default-icon";
            prefix = "?";
            show_icon_when_single = true;
          };
        };

        # https://github.com/abenz1267/walker/wiki/Plugins
        plugins = [
          # Search engines by keyword prefix
          {
            name = "search";
            placeholder = "";
            show_icon_when_single = true;
            switcher_only = true;

            src = "${pkgs.writeShellApplication {
              name = "search";
              text = builtins.readFile ./search.sh;

              runtimeInputs = with pkgs; [
                coreutils
                jq
                xdg-utils
              ];
            }}/bin/search '%TERM%'";
          }
        ];
      };

      # https://github.com/abenz1267/walker/wiki/Theming
      theme = {
        style = ''
          #box {
            font: larger ${config.custom.font.sans-serif};
          }

          placeholder {
            font: larger ${config.custom.font.monospace};
          }

          ${builtins.readFile ./style.css}
        '';

        #!! Inherit from default layout
        # https://github.com/abenz1267/walker/blob/master/internal/config/layout.default.json
        layout.ui.window = let
          w = 750;
          h = 250;
        in {
          width = w;
          height = h;

          box = {
            h_align = "fill";
            width = -1;
            height = -1;

            ai_scroll = {
              # BUG: AiScroll H/VScrollbarPolicy applies to Scroll widget
              h_scrollbar_policy = "external";
              v_scrollbar_policy = "external";
            };

            scroll = {
              h_align = "fill";
              h_scrollbar_policy = "external";
              v_scrollbar_policy = "external";

              list = {
                width = -1;
                height = -1;
                min_width = -1;
                min_height = -1;
                max_width = w;
                max_height = h;

                item = {
                  icon = {
                    icon_size = "larger"; # 64px
                    pixel_size = 32; # Downscale
                  };

                  text = {
                    sub = {
                      hide = true; # Subtext
                    };
                  };
                };
              };
            };

            search = {
              input = {
                icons = false;
              };
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
