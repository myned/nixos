{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland.rules;
  hm = config.home-manager.users.${config.custom.username};

  _1password = getExe config.programs._1password-gui.package;
  gamescope = getExe config.programs.gamescope.package;
  ghostty = getExe hm.programs.ghostty.package;
  launch = hm.home.file.".local/bin/launch".source;
  libreoffice = getExe config.custom.programs.libreoffice.package;
  loupe = getExe pkgs.loupe;
  steam = getExe config.programs.steam.package;
  uwsm = getExe pkgs.uwsm;
  virt-manager = getExe pkgs.virt-manager;
  waydroid = getExe pkgs.waydroid;

  command = command: "${uwsm} app -- ${command}";
  youtube-music = getExe pkgs.youtube-music;
in {
  options.custom.desktops.hyprland.rules = {
    enable = mkOption {default = false;};
  };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # BUG: on-created-empty race condition with delayed windows
      # https://github.com/hyprwm/Hyprland/issues/5663
      # https://wiki.hyprland.org/Configuring/Workspace-Rules
      #?? workspace = WORKSPACE, RULES
      workspace = [
        "special:android, on-created-empty:${command "${launch} --workspace special:android --empty ${waydroid} app launch com.YoStarEN.Arknights"}"
        "special:game, on-created-empty:${command steam}"
        "special:music, on-created-empty:${command youtube-music}"
        "special:office, on-created-empty:${command "${launch} --workspace special:office --empty --tile -- ${libreoffice}"}"
        "special:password, on-created-empty:${command "${launch} --workspace special:password --empty ${_1password}"}"
        "special:terminal, on-created-empty:${command ghostty}"
        "special:vm, on-created-empty:${command "${launch} --workspace special:vm --empty ${virt-manager}"}"
        "special:wallpaper, on-created-empty:${command "${loupe} /tmp/wallpaper.png"}"
      ];

      # https://wiki.hyprland.org/Configuring/Window-Rules
      #?? windowrulev2 = RULE, WINDOW
      windowrulev2 = with config.custom; let
        gaps_in = gap / 4;

        # HACK: Attempts to account for hypr-specific scale, gaps, borders, and bar padding
        ### Static geometry rules
        tr = num: toString (builtins.floor num); # Convert truncated float to string

        # Bottom center
        android = rec {
          x = tr (width / scale / 2 - (toInt w) / 2);

          y = tr (height
            / scale
            - (toInt h)
            - gap
            - padding
            + (
              if ultrawide
              then - border # Cause unknown
              else 0
            ));

          w = tr (
            width
            / scale
            * (
              if ultrawide
              then 3.0 / 8.0 # threeeighths
              else 1.0 # one
            )
            + (
              if ultrawide
              then - gaps_in * 2
              else - gap * 2
            )
            - border * 2
          );

          h = tr (height / scale * 0.5);
        };

        # Bottom center
        clipboard = rec {
          x = tr (width / scale / 2 - (toInt w) / 2);

          y = tr (height
            / scale
            - (toInt h)
            - gap
            - padding
            + (
              if ultrawide
              then - border # Cause unknown
              else 0
            ));

          w = "600";
          h = tr (height / scale * 0.75);
        };

        # Bottom center
        dropdown = rec {
          x = tr (width / scale / 2 - (toInt w) / 2);

          y = tr (height
            / scale
            - (toInt h)
            - gap
            - padding
            + (
              if ultrawide
              then - border # Cause unknown
              else 0
            ));

          w = tr (
            width
            / scale
            * (
              if ultrawide
              then 3.0 / 8.0 # threeeighths
              else 1.0 # one
            )
            + (
              if ultrawide
              then - gaps_in * 2
              else - gap * 2
            )
            - border * 2
          );

          h = tr (height
            / scale
            * (
              if ultrawide
              then 0.2
              else 0.3
            ));
        };

        # Top right
        pip = rec {
          x = tr (width / scale - (toInt w) - gap - border);
          y = tr (gap + border);

          w = tr (
            width
            / scale
            * (
              if ultrawide
              then (1 - 3.0 / 8.0) / 2 # threeeighths / 2
              else 1.0 / 3.0 # onethird
            )
            - gap
            - gaps_in
            - border * 2
          );

          h = tr ((toInt w) * 9 / 16 + 1); # 16:9 aspect ratio
        };

        ### Rules
        # Return hypr-formatted string, converting booleans into 0/1
        format = field: expr: "${field}:${
          toString (
            if expr == true
            then 1
            else if expr == false
            then 0
            else expr
          )
        }";

        # Generate hypr-formatted window rules
        #?? merge <FIELD|{FIELDS}> <EXPRESSION> <RULES>
        merge = field: expr: rules:
          map (
            rule:
              if isAttrs field
              then "${rule}, ${lib.concatStringsSep ", " (lib.mapAttrsToList (f: e: format f e) field)}"
              else "${rule}, ${format field expr}"
          )
          rules;

        class = expr: rules: merge "class" "^${expr}$" rules;
        fields = fields: rules: merge fields null rules;
        floating = expr: rules: merge "floating" expr rules;
        focus = expr: rules: merge "focus" expr rules;
        fullscreen = expr: rules: merge "fullscreen" expr rules;
        pinned = expr: rules: merge "pinned" expr rules;
        tag = expr: rules: merge "tag" expr rules;
        title = expr: rules: merge "title" "^${expr}$" rules;

        ### Pseudo-tags
        # Wrap generated rules in Nix categories
        t = {
          android = rules: [
            (class "[Ww]aydroid.*" rules)
          ];

          browser = rules: [
            (class "^brave-browser$" rules)
            (class "^chromium-browser$" rules)
            (class "^firefox.*$" rules)
            (class "^google-chrome$" rules)
            (class "^vivaldi.*$" rules)
          ];

          clipboard = rules: [
            (class "clipboard" rules)
          ];

          dropdown = rules: [
            (class ".*dropdown" rules)
          ];

          editor = rules: [
            (class "codium" rules) # VSCode
            (class "obsidian" rules)
          ];

          files = rules: [
            (class "org\\.gnome\\.Nautilus" rules)
          ];

          game = rules: [
            (class ".*\\.(exe|x86_64)" rules) # Wine
            (class "moe\\.launcher\\..+" (rules ++ ["size 1280 730" "plugin:hyprbars:nobar"])) # An Anime Game Launcher
            (class "net.retrodeck.retrodeck" rules) # Emulators
            (class "steam_app_.+" rules) # Proton
          ];

          media = rules: [
            (class "org\\.gnome\\.Loupe" rules)
            (class "totem" rules)
          ];

          music = rules: [
            (class "Spotify" rules)
            (class "YouTube Music" rules)
            (title "Spotify Premium" rules)
          ];

          office = rules: [
            (class "draw\\.io" rules)
            (class "libreoffice.+" rules)
            (class "ONLYOFFICE Desktop Editors" rules)
          ];

          password = rules: [
            (class "1Password" rules)
            (class "Bitwarden" rules)
          ];

          pip = rules: [
            (title "Picture.in.[Pp]icture" rules)
          ];

          social = rules: [
            (class "cinny" rules)
            (class "discord" rules)
            (class "Element" rules)
            (class "org\\.telegram\\.desktop" rules)
          ];

          steam = rules: [
            (class "SDL Application" rules) # Steam
            (class "steam" rules)
          ];

          terminal = rules: [
            (class "foot" rules)
            (class "com\\.mitchellh\\.ghostty" rules)
            (class "kitty" rules)
            (class "org\\.wezfurlong\\.wezterm" rules)
          ];

          vm = rules: [
            (class "(sdl-|wl|x)freerdp" (rules ++ ["nomaxsize" "tile"]))
            (class "looking-glass-client" (rules ++ ["plugin:hyprbars:nobar"]))
            (class "org\\.remmina\\.Remmina" (rules ++ ["tile"]))
            (class "virt-manager" rules)
          ];
        };
      in
        flatten [
          ### Defaults
          (floating false ["noshadow" "plugin:hyprbars:nobar"])
          (floating true ["noborder"])
          (focus false ["plugin:hyprbars:bar_color rgb(073642)" "plugin:hyprbars:title_color rgb(586e75)"])
          (fullscreen true ["idleinhibit focus"])
          (pinned true ["bordercolor rgb(fdf6e3) rgb(fdf6e300)" "noborder 0" "noshadow"])

          (tag "scroller:pinned" ["bordercolor rgb(fdf6e3) rgb(fdf6e300)"])

          (t.android ["float" "idleinhibit always" "move ${android.x} ${android.y}" "size ${android.w} ${android.h}" "workspace special:android silent" "plugin:hyprbars:nobar"])
          (t.browser ["workspace 1"])
          (t.clipboard ["float" "move ${clipboard.x} ${clipboard.y}" "pin" "size ${clipboard.w} ${clipboard.h}" "stayfocused" "plugin:hyprbars:nobar"])
          (t.dropdown ["float" "move ${dropdown.x} ${dropdown.y}" "pin" "size ${dropdown.w} ${dropdown.h}" "plugin:hyprbars:nobar"])
          (t.game ["focusonactivate" "idleinhibit always" "noborder" "noshadow" "renderunfocused" "workspace name:game" "plugin:hyprbars:nobar"])
          (t.media ["center" "float" "keepaspectratio" "size <90% <90%"])
          (t.music ["workspace special:music silent"])
          (t.office ["workspace special:office silent" "plugin:scroller:group office"])
          (t.password ["workspace special:password silent" "plugin:hyprbars:nobar"])
          (t.pip ["float" "keepaspectratio" "move ${pip.x} ${pip.y}" "noinitialfocus" "pin" "size ${pip.w} ${pip.h}" "plugin:hyprbars:nobar"])
          (t.social ["plugin:scroller:group social" "plugin:scroller:columnwidth onequarter" "plugin:scroller:windowheight onehalf"])
          (t.steam ["suppressevent activate activatefocus" "workspace special:steam silent" "plugin:hyprbars:nobar"])
          (t.terminal ["plugin:scroller:group terminal"])
          (t.vm ["workspace special:vm silent" "plugin:scroller:group vm"])

          ### Overrides
          (class "org\\.gnome\\.NautilusPreviewer" ["float" "stayfocused" "plugin:hyprbars:nobar"]) # Sushi
          (class "steam_app_1473350" ["workspace 0"]) # (the) Gnorp Apologue
          (class "Tap Wizard 2\\.x86_64" ["workspace 0"])

          #!! Expressions are not wrapped in ^$
          (fields {
            class = "^discord$";
            title = "^Discord Updater$"; # Update dialog
          } ["float" "nofocus" "plugin:hyprbars:nobar"])
          (fields {
            class = "^org\\.gnome\\.Loupe$";
            title = "^wallpaper.png$";
          } ["workspace special:wallpaper silent"])
          (fields {
            class = "^steam$";
            title = "^notificationtoasts$"; # Steam notifications
          } ["float" "nofocus" "pin"])
        ];
    };
  };
}
