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
              geometry-corner-radius = let
                radius = config.custom.rounding + 0.0; # Convert to float
              in {
                top-left = radius;
                top-right = radius;
                bottom-right = radius;
                bottom-left = radius;
              };

              clip-to-geometry = true;
            }

            {
              # Floating
              matches = [{is-floating = true;}];

              border.enable = false;
              focus-ring.enable = false;
            }

            {
              # Startup
              #?? <= 60 secs after niri launches
              matches = [
                {at-startup = true;}
                {app-id = "^org\.gnome\.Loupe$";}
                {app-id = "^org\.gnome\.Nautilus$";}
              ];

              open-focused = false;
              open-on-workspace = "1";
            }

            {
              # Android
              matches = [{app-id = "^[Ww]aydroid.*$";}];
            }

            {
              # Browsers
              matches = [
                {app-id = "^brave-browser$";}
                {app-id = "^chromium-browser$";}
                {app-id = "^firefox.*$";}
                {app-id = "^google-chrome$";}
                {app-id = "^vivaldi.*$";}
              ];

              default-column-width.proportion =
                if config.custom.ultrawide
                then 0.4
                else 0.7;

              open-on-workspace = "2";
            }

            {
              # Chats
              matches = [
                {app-id = "^cinny$";}
                {app-id = "^discord$";}
                {app-id = "^Element$";}
                {app-id = "^org\.telegram\.desktop$";}
              ];
            }

            {
              # Dropdown terminal
              matches = [{app-id = "^dropdown$";}];
            }

            {
              # Editors
              matches = [
                {app-id = "^codium$";}
                {app-id = "^obsidian$";}
              ];

              open-on-workspace = "2";
            }

            {
              # Files
              matches = [{app-id = "^org\.gnome\.Nautilus$";}];
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
              open-on-workspace = "1";
              variable-refresh-rate = true;
            }

            {
              # Media
              matches = [
                {
                  app-id = "^org\.gnome\.Loupe$";
                  title = "wallpaper.png";
                }

                {app-id = "^Spotify$";}
                {app-id = "^totem$";}
                {app-id = "^YouTube Music$";}
              ];

              open-on-workspace = "3";
            }

            {
              # Office
              matches = [
                {app-id = "^draw\.io$";}
                {app-id = "^libreoffice$";}
                {app-id = "^ONLYOFFICE Desktop Editors$";}
              ];

              open-on-workspace = "2";
            }

            (let
              # BUG: Fixed width may not take borders into account
              # https://github.com/YaLTeR/niri/issues/269
              pip = with config.custom; rec {
                x = gap;
                y = gap;
                w = builtins.floor (width * 0.3 - gap); # 30%
                h = builtins.floor (w * 9 / 16); # 16:9
              };
            in {
              # PiP
              matches = [{title = "^Picture.in.[Pp]icture$";}];

              default-floating-position = {
                x = pip.x;
                y = pip.y;
                relative-to = "top-right";
              };

              default-column-width.fixed = pip.w;
              default-window-height.fixed = pip.h;
              open-floating = true;
              open-focused = false;
            })

            {
              # Terminals
              matches = [
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
                {app-id = "^virt-manager$";}
              ];

              open-floating = false;
              open-on-workspace = "1";
            }

            ### Overrides
            # TODO: Remove when switching 1Password to Wayland
            (let
              height = builtins.floor (config.custom.height / config.custom.scale * 0.4); # 40%
            in {
              matches = [
                {
                  app-id = "^1Password";
                  title = "^Quick Access — 1Password$";
                }
              ];

              max-height = height;
              min-height = height;
              open-floating = true;
            })
          ];
        };
      }
    ];
  };
}
