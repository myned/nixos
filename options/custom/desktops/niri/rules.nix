{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.rules;
in {
  options.custom.desktops.niri.rules = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
        programs.niri.settings = {
          # HACK: Name workspaces after index to use open-on-workspace rule
          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsworkspaces
          #?? niri msg workspaces
          # workspaces = {
          #   "1" = {};
          #   "2" = {};
          #   "3" = {};
          # };

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingswindow-rules
          #?? niri msg windows
          window-rules = [
            ### Defaults
            {
              # Global
              geometry-corner-radius = with config.custom; {
                top-left = rounding;
                top-right = rounding;
                bottom-right = rounding;
                bottom-left = rounding;
              };

              clip-to-geometry = true;
            }

            {
              # Floating
              matches = [
                {is-floating = true;}
              ];

              border.enable = false;
              focus-ring.enable = false;
              shadow.enable = true;
            }

            {
              # Startup
              #?? <= 60 secs after niri launches
              matches = [
                {at-startup = true;}
              ];
            }

            {
              # Android
              matches = [
                {app-id = "^[Ww]aydroid.*$";}
              ];
            }

            {
              # Browsers
              matches = [
                {app-id = "^brave-browser$";}
                {app-id = "^chromium-browser$";}
                {app-id = "^firefox.*$";}
                {app-id = "^google-chrome$";}
                {app-id = "^librewolf$";}
                {app-id = "^vivaldi.*$";}
                {app-id = "^zen$";}
              ];

              excludes = [
                {title = "^Picture.in.[Pp]icture$";}
              ];

              default-column-width.proportion =
                if config.custom.ultrawide
                then 0.4
                else 0.8;
            }

            {
              # Chats
              matches = [
                {app-id = "^cinny$";}
                {app-id = "^de\.schmidhuberj\.Flare$";}
                {app-id = "^discord$";}
                {app-id = "^Element$";}
                {app-id = "^fluffychat$";}
                {app-id = "^nheko$";}
                {app-id = "^org\.gnome\.Fractal$";}
                {app-id = "^org\.telegram\.desktop$";}
                {app-id = "^signal$";}
                {app-id = "^so\.libdb\.dissent$";}
              ];

              default-column-display = "tabbed";
            }

            {
              # Dropdown terminal
              matches = [
                {app-id = "^dropdown$";}
              ];

              open-floating = true;
            }

            {
              # Editors
              matches = [
                {app-id = "^obsidian$";}
                {app-id = "^org\.gnome\.TextEditor$";}
                {app-id = "^org\.wireshark\.Wireshark$";}
              ];
            }

            {
              # Files
              matches = [
                {app-id = "^org\.gnome\.Nautilus$";}
              ];
            }

            {
              # Games
              matches = [
                {app-id = "^.*\.(exe|x86_64)$";}
                {app-id = "^love$";} # vrrtest
                {app-id = "^moe\.launcher\..+$";} # Anime Game Launcher
                {app-id = "^net\.retrodeck\.retrodeck$";}
                {app-id = "^steam_app_.+$";}
              ];

              default-column-width = {}; # Window-defined
              variable-refresh-rate = true;
            }

            {
              # IDEs
              matches = [
                {app-id = "^codium$";}
                {app-id = "^dev\.zed\.Zed$";}
              ];

              default-column-width.proportion =
                if config.custom.ultrawide
                then 0.4
                else 0.8;
            }

            {
              # Media
              matches = [
                {app-id = "^com\.github\.th_ch\.youtube_music$";}
                {app-id = "^org\.gnome\.Loupe$";}
                {app-id = "^Spotify$";}
                {app-id = "^totem$";}
                {app-id = "^YouTube Music$";}
              ];
            }

            {
              # Office
              matches = [
                {app-id = "^draw\.io$";}
                {app-id = "^libreoffice.*$";}
                {app-id = "^ONLYOFFICE$";}
                {app-id = "^org\.gnome\.Papers$";}
              ];
            }

            (let
              pip = with config.custom; rec {
                x = gap - border * 2;
                y = gap;
                w = builtins.floor (width * 0.25 - gap * 2 + border * 2 + border + 1); # 25%
                h = builtins.floor (w * 9 / 16); # 16:9
              };
            in {
              # PiP
              matches = [
                {title = "^Picture.in.[Pp]icture$";}
              ];

              default-floating-position = {
                relative-to = "top-right";
                x = pip.x;
                y = pip.y;
              };

              default-column-width.fixed = pip.w;
              default-window-height.fixed = pip.h;
              open-floating = true;
              open-focused = false;
            })

            {
              # Steam
              matches = [
                {app-id = "^steam$";}
              ];
            }

            {
              # Terminals
              matches = [
                {app-id = "^com\.mitchellh\.ghostty$";}
                {app-id = "^foot$";}
                {app-id = "^kitty$";}
                {app-id = "^org\.wezfurlong\.wezterm$";}
              ];
            }

            {
              # Vaults
              matches = [
                {app-id = "^1Password$";}
                {app-id = "^Bitwarden$";}
              ];
            }

            {
              # Virtual machines
              matches = [
                {app-id = "^(sdl-|wl|x)freerdp$";}
                {app-id = "^looking-glass-client$";}
                {app-id = "^org\.remmina\.Remmina$";}
                {app-id = "^.*virt-manager.*$";}
              ];
            }

            ### Overrides
            # TODO: Remove when switching 1Password to Wayland
            (let
              height = builtins.floor (config.custom.height * 0.4); # 40%
            in {
              # 1Password Quick Access
              matches = [
                {
                  app-id = "^1Password";
                  title = "^Quick Access — 1Password$";
                }
              ];

              open-floating = true;
              max-height = height;
              min-height = height;
            })

            {
              # Sushi
              matches = [
                {app-id = "^org\.gnome\.NautilusPreviewer$";}
              ];

              default-column-width = {};
              open-floating = true;
            }
          ];
        };
      }
    ];
  };
}
