{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.menus.walker;
  hm = config.home-manager.users.${config.custom.username};

  notify-send = getExe pkgs.libnotify;
  rm = getExe' pkgs.coreutils "rm";
  walker = getExe hm.programs.walker.package;
in {
  options.custom.menus.walker = {
    enable = mkOption {default = false;};
    icons = mkOption {default = ["edit-find" "terminal"];};
  };

  config = mkIf cfg.enable {
    custom = {
      menus = mkIf (config.custom.menu == "walker") {
        show = walker;

        clipboard = {
          show = "${walker} --modules clipboard";
          clear = "${rm} ~/.cache/walker/clipboard.gob && ${notify-send} '> walker' 'Clipboard cleared' --urgency low";
        };

        dmenu.show = "${walker} --modules dmenu";
        emoji.show = "${walker} --modules emojis";
        search.show = "${walker} --modules search";
        vault.show = "";
      };

      services = {
        clipnotify.enable = true;
      };
    };

    home-manager.sharedModules = [
      {
        # https://github.com/abenz1267/walker
        # https://github.com/abenz1267/walker?tab=readme-ov-file#building-from-source
        # https://github.com/abenz1267/walker/blob/master/nix/hm-module.nix
        programs.walker = {
          enable = true;

          #!! Service must be restarted for changes to take effect
          #?? systemctl --user restart walker.service
          runAsService = true;

          # https://github.com/abenz1267/walker/wiki/Basic-Configuration
          # https://github.com/abenz1267/walker/blob/master/internal/config/config.default.toml
          config = {
            activation_mode.disabled = true; # Key chords
            close_when_open = true;
            disable_click_to_close = true;
            force_keyboard_focus = true;
            hotreload_theme = true;
            ignore_mouse = true;

            list = {
              placeholder = "";
            };

            search = {
              placeholder = "";
              #// resume_last_query = true;
            };

            # https://github.com/abenz1267/walker/wiki/Modules
            # https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/tree/master/Papirus/64x64
            disabled = [
              "ai"
              "commands"
              "custom_commands"
              "finder"
              "websearch" # Replaced by custom plugin
              "windows"
            ];

            builtins = let
            in {
              applications = {
                actions.enabled = false;
                hide_without_query = true;
                placeholder = "";
                show_generic = false;
                switcher_only = false;
              };

              bookmarks = {
                icon = "user-bookmarks";
                placeholder = "";
                prefix = "b ";
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
                placeholder = "Input";
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
                prefix = "//";
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
                prefix = "ssh ";
                show_icon_when_single = true;
                switcher_only = false;
              };

              switcher = {
                icon = "application-default-icon";
                prefix = "/";
                show_icon_when_single = true;
              };

              symbols = {
                placeholder = "";
                prefix = "sym ";
                switcher_only = false;
              };

              translation = {
                icon = "translator";
                placeholder = "";
                prefix = "tr ";
                switcher_only = false;
              };

              websearch = {
                placeholder = "system-search";
                switcher_only = false;
                entries = [{}];
              };
            };

            # TODO: Keybinds
            # https://github.com/abenz1267/walker/wiki/Keybinds

            # https://github.com/abenz1267/walker/wiki/Plugins
            plugins = [
              {
                # Search engines by keyword prefix
                name = "search";
                placeholder = "";
                show_icon_when_single = true;
                switcher_only = false;

                src = "${pkgs.writeShellApplication {
                  name = "search";
                  text = readFile ./search.sh;
                  runtimeInputs = with pkgs; [coreutils jq xdg-utils];
                }}/bin/search '%TERM%'";
              }
            ];
          };

          # https://github.com/abenz1267/walker/wiki/Theming
          theme = {
            style = ''
              #box {
                border: ${toString config.custom.border}px #073642 solid;
                font: larger ${config.custom.settings.fonts.sans-serif};
              }

              ${readFile ./style.css}
            '';

            # https://github.com/abenz1267/walker/blob/master/internal/config/layout.default.toml
            layout.ui.window = let
              w = 750;
              h = 300;
            in {
              width = w;
              height = h;

              box = {
                h_align = "fill";
                width = -1;
                height = -1;

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
                      text = {
                        sub = {
                          hide = true; # Subtext
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      }
    ];

    # # HACK: Create theme files for module prompt icons
    # #?? MODULE.theme = "icon-ICON"
    # # https://github.com/abenz1267/walker/blob/bb584eab3b0cc48ebfbac1a5da019864d74781c4/nix/hm-module.nix#L86
    # xdg.configFile = listToAttrs (flatten (forEach cfg.icons (
    #   icon: [
    #     {
    #       name = "walker/themes/icon-${icon}.css";
    #       value = {text = hm.programs.walker.theme.style;};
    #     }
    #     {
    #       name = "walker/themes/icon-${icon}.json";
    #       value = {
    #         text = builtins.toJSON (recursiveUpdate hm.programs.walker.theme.layout {
    #           ui.window.box.search.prompt.icon = icon;
    #         });
    #       };
    #     }
    #   ]
    # )));

    # HACK: Allow child processes to live, otherwise applications launched through service are killed on stop
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.kill.html#KillMode=
    systemd.user.services.walker.Service.KillMode = "process";
  };
}
