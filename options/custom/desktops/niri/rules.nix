{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.rules;
in {
  options.custom.desktops.niri.rules = {
    enable = mkEnableOption "rules";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
        wayland.windowManager.niri.settings = {
          #?? niri msg windows
          window-rule = let
            android = [
              {_props.app-id = "^[Ww]aydroid.*$";}
            ];

            browsers = [
              {_props.app-id = "^brave-browser.*$";}
              {_props.app-id = "^chromium-browser.*$";}
              {_props.app-id = "^firefox.*$";}
              {_props.app-id = "^[Gg]oogle-chrome.*$";}
              {_props.app-id = "^librewolf.*$";}
              {_props.app-id = "^vivaldi.*$";}
              {_props.app-id = "^zen.*$";}
            ];

            chats = [
              {_props.app-id = "^cinny$";}
              {_props.app-id = "^de\.schmidhuberj\.Flare$";}
              {_props.app-id = "^discord$";}
              {_props.app-id = "^Element$";}
              {_props.app-id = "^fluffychat$";}
              {_props.app-id = "^nheko$";}
              {_props.app-id = "^org\.gnome\.Fractal$";}
              {_props.app-id = "^org\.telegram\.desktop$";}
              {_props.app-id = "^signal$";}
              {_props.app-id = "^so\.libdb\.dissent$";}
              {_props.app-id = "^vesktop$";}
            ];

            dropdown = [
              {_props.app-id = "^dropdown$";}
            ];

            editors = [
              {_props.app-id = "^org\.gnome\.TextEditor$";}
              {_props.app-id = "^org\.wireshark\.Wireshark$";}
            ];

            files = [
              {_props.app-id = "^org\.gnome\.Nautilus$";}
            ];

            games = [
              {_props.app-id = "^.*\.(exe|x86_64)$";}
              {_props.app-id = "^love$";} # vrrtest
              {_props.app-id = "^moe\.launcher\..+$";} # Anime Game Launcher
              {_props.app-id = "^net\.retrodeck\.retrodeck$";}
              {_props.app-id = "^steam_app_.+$";}
            ];

            ides = [
              {_props.app-id = "^Capacities$";}
              {_props.app-id = "^code$";}
              {_props.app-id = "^codium$";}
              {_props.app-id = "^dev\.zed\.Zed$";}
              {_props.app-id = "^GitHub Desktop$";}
              {_props.app-id = "^obsidian$";}
            ];

            media = [
              {_props.app-id = "^com\.github\.th_ch\.youtube_music$";}
              {_props.app-id = "^org\.gnome\.Loupe$";}
              {_props.app-id = "^Spotify$";}
              {_props.app-id = "^totem$";}
              {_props.app-id = "^YouTube Music$";}
            ];

            office = [
              {_props.app-id = "^draw\.io$";}
              {_props.app-id = "^libreoffice.*$";}
              {_props.app-id = "^ONLYOFFICE$";}
              {_props.app-id = "^org\.gnome\.Papers$";}
            ];

            picture-in-picture = [
              {_props.title = "^Picture.in.[Pp]icture$";}
            ];

            previewer = [
              {_props.app-id = "^org\.gnome\.NautilusPreviewer$";}
            ];

            steam = [
              {_props.app-id = "^steam$";}
            ];

            tasks = [
              {_props.app-id = "^Todoist$";}
            ];

            terminals = [
              {_props.app-id = "^com\.mitchellh\.ghostty$";}
              {_props.app-id = "^foot$";}
              {_props.app-id = "^kitty$";}
              {_props.app-id = "^org\.wezfurlong\.wezterm$";}
            ];

            vaults = [
              {_props.app-id = "^1Password$";}
              {_props.app-id = "^Bitwarden$";}
              {_props.app-id = "^com-artemchep-keyguard-MainKt$";}
              {
                _props = {
                  app-id = "^electron$";
                  title = "^Proton Pass$";
                };
              }
            ];

            vms = [
              {_props.app-id = "^(sdl-|wl|x)freerdp$";}
              {_props.app-id = "^looking-glass-client$";}
              {_props.app-id = "^org\.remmina\.Remmina$";}
              {_props.app-id = "^.*virt-manager.*$";}
            ];

            work = [
              {_props.app-id = "^.*work$";}
              {_props.title = "^.*[Ww]ork$";}
            ];
          in [
            ### Defaults
            {
              # Global
              clip-to-geometry = true;
              draw-border-with-background = false;
              geometry-corner-radius = config.custom.rounding;
            }

            {
              # Global floating
              match._props.is-floating = true;
              baba-is-float = true;
              border.off = [];
              default-column-width = {};
              default-window-height = {};
              focus-ring.off = [];
              shadow.on = [];
            }

            {
              # Global startup
              #?? <= 60 secs after niri launches
              match._props.at-startup = true;
            }

            {
              # Android
              match = android;
            }

            {
              # Browsers
              match = browsers;
              exclude = picture-in-picture;
              default-column-width.proportion =
                if config.custom.displays.default.ultrawide
                then 0.4
                else 0.8;
            }

            {
              # Chats
              match = chats;
              default-column-display = "tabbed";
            }

            {
              # Dropdown terminal
              match = dropdown;
              open-floating = true;
            }

            {
              # Editors
              match = editors;
            }

            {
              # Files
              match = files;
            }

            {
              # Games
              match = games;
              open-floating = false;
              open-focused = true;
              open-fullscreen = true;
              shadow.off = [];
            }

            {
              # Games (focused)
              match = forEach games (game: recursiveUpdate game {_props.is-focused = true;});
              variable-refresh-rate = true;
            }

            {
              # IDEs
              match = ides;
              default-column-width.proportion =
                if config.custom.displays.default.ultrawide
                then 0.5
                else 0.8;
            }

            {
              # Media
              match = media;
            }

            {
              # Office
              match = office;
            }

            (let
              pip = with config.custom;
              with config.custom.displays.default; rec {
                x = gap - border * 2;
                y = gap;
                w = builtins.floor (width * 0.2 - gap * 2 + border * 2 + border + 1); # 20%
                h = builtins.floor (w * 9 / 16); # 16:9
              };
            in {
              # PiP
              match = picture-in-picture;
              baba-is-float = false;
              default-column-width.fixed = pip.w;
              default-window-height.fixed = pip.h;
              default-floating-position._props.relative-to = "top-right";
              default-floating-position._props.x = pip.x;
              default-floating-position._props.y = pip.y;
              open-floating = true;
              open-focused = false;
            })

            {
              # Previewer
              match = previewer;
              default-column-width.proportion =
                if config.custom.displays.default.ultrawide
                then 0.4
                else 0.8;
              default-window-height.proportion = 0.8;
              open-floating = true;
            }

            {
              # Steam
              match = steam;
            }

            {
              # Tasks
              match = tasks;
              default-column-width.proportion = 0.2;
            }

            {
              # Terminals
              match = terminals;
            }

            {
              # Vaults
              match = vaults;
              default-column-width.proportion =
                if config.custom.displays.default.ultrawide
                then 0.4
                else 0.8;
            }

            {
              # Virtual machines
              match = vms;
            }

            {
              # Work
              match = work;
              border.active-color = "#cb4b16";
              focus-ring.active-color = "#cb4b16";
            }

            ### Overrides
            {
              # Steam notifications
              # https://github.com/YaLTeR/niri/wiki/Application-Issues#steam
              match._props = {
                app-id = "^steam$";
                title = "^notificationtoasts.*$";
              };

              default-floating-position._props.x = config.custom.gap;
              default-floating-position._props.y = config.custom.gap;
              default-floating-position._props.relative-to = "bottom-right";
              open-focused = false;
            }
          ];
        };
      }
    ];
  };
}
