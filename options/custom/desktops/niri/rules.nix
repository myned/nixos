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
          window-rules = let
            forEachMatch = matches: rule:
              if isNull matches
              then [rule]
              else forEach matches (match: match // rule);

            floating = matches: forEachMatch matches {is-floating = true;};
            focused = matches: forEachMatch matches {is-focused = true;};
            startup = matches: forEachMatch matches {at-startup = true;};

            app-id = app-id: {inherit app-id;};
            title = title: {inherit title;};

            app-ids = ids: forEach ids (id: app-id id);
            titles = ids: forEach ids (id: title id);

            android = app-ids [
              "^[Ww]aydroid.*$"
            ];

            browsers = app-ids [
              "^brave-browser$"
              "^chromium-browser$"
              "^firefox.*$"
              "^google-chrome$"
              "^librewolf$"
              "^vivaldi.*$"
              "^zen$"
            ];

            chats = app-ids [
              "^cinny$"
              "^de\.schmidhuberj\.Flare$"
              "^discord$"
              "^Element$"
              "^fluffychat$"
              "^nheko$"
              "^org\.gnome\.Fractal$"
              "^org\.telegram\.desktop$"
              "^signal$"
              "^so\.libdb\.dissent$"
              "^vesktop$"
            ];

            dropdown = app-ids [
              "^dropdown$"
            ];

            editors = app-ids [
              "^obsidian$"
              "^org\.gnome\.TextEditor$"
              "^org\.wireshark\.Wireshark$"
            ];

            files = app-ids [
              "^org\.gnome\.Nautilus$"
            ];

            games = app-ids [
              "^.*\.(exe|x86_64)$"
              "^love$" # vrrtest
              "^moe\.launcher\..+$" # Anime Game Launcher
              "^net\.retrodeck\.retrodeck$"
              "^steam_app_.+$"
            ];

            ides = app-ids [
              "^codium$"
              "^dev\.zed\.Zed$"
              "^GitHub Desktop$"
            ];

            media = app-ids [
              "^com\.github\.th_ch\.youtube_music$"
              "^org\.gnome\.Loupe$"
              "^Spotify$"
              "^totem$"
              "^YouTube Music$"
            ];

            office = app-ids [
              "^draw\.io$"
              "^libreoffice.*$"
              "^ONLYOFFICE$"
              "^org\.gnome\.Papers$"
            ];

            picture-in-picture = titles [
              "^Picture.in.[Pp]icture$"
            ];

            previewer = app-ids [
              "^org\.gnome\.NautilusPreviewer$"
            ];

            steam = app-ids [
              "^steam$"
            ];

            terminals = app-ids [
              "^com\.mitchellh\.ghostty$"
              "^foot$"
              "^kitty$"
              "^org\.wezfurlong\.wezterm$"
            ];

            vaults = app-ids [
              "^1Password$"
              "^Bitwarden$"
              "^com-artemchep-keyguard-MainKt$"
            ];

            vms = app-ids [
              "^(sdl-|wl|x)freerdp$"
              "^looking-glass-client$"
              "^org\.remmina\.Remmina$"
              "^.*virt-manager.*$"
            ];
          in [
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
              draw-border-with-background = false;
            }

            {
              # Global floating
              matches = floating null;
              border.enable = false;
              focus-ring.enable = false;
              shadow.enable = true;
            }

            {
              # Global startup
              #?? <= 60 secs after niri launches
              matches = startup null;
            }

            {
              # Android
              matches = android;
            }

            {
              # Browsers
              matches = browsers;
              excludes = picture-in-picture;
              default-column-width.proportion =
                if config.custom.ultrawide
                then 0.4
                else 0.8;
            }

            {
              # Chats
              matches = chats;
              default-column-display = "tabbed";
            }

            {
              # Dropdown terminal
              matches = dropdown;
              open-floating = true;
            }

            {
              # Editors
              matches = editors;
            }

            {
              # Files
              matches = files;
            }

            {
              # Games
              matches = games;
            }

            {
              # Games (focused)
              matches = focused games;
              variable-refresh-rate = true;
            }

            {
              # IDEs
              matches = ides;
              default-column-width.proportion =
                if config.custom.ultrawide
                then 0.4
                else 0.8;
            }

            {
              # Media
              matches = media;
            }

            {
              # Office
              matches = office;
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
              matches = picture-in-picture;

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
              # Previewer
              matches = previewer;
              default-column-width = {};
              open-floating = true;
            }

            {
              # Steam
              matches = steam;
            }

            {
              # Terminals
              matches = terminals;
            }

            {
              # Vaults
              matches = vaults;
              default-column-width.proportion =
                if config.custom.ultrawide
                then 0.4
                else 0.8;
            }

            {
              # Virtual machines
              matches = vms;
            }

            ### Overrides
            # TODO: Remove when switching 1Password to Wayland
            (let
              height = builtins.floor (config.custom.height * 0.4); # 40%
            in {
              # 1Password Quick Access
              matches = [((app-id "^1Password") // (title "^Quick Access — 1Password$"))];
              open-floating = true;
              max-height = height;
              min-height = height;
            })

            {
              # Rofi
              # FIXME: Figure out why pinentry-rofi opens as a window
              # HACK: pinentry-rofi opens as a window, so attempt to style as a layer
              matches = app-ids ["^Rofi$"];
              border.enable = false;
              clip-to-geometry = false;
              focus-ring.enable = false;
              open-floating = true;
              shadow.enable = false;
            }
          ];
        };
      }
    ];
  };
}
