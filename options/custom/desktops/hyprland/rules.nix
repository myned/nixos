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
  virt-manager = getExe pkgs.virt-manager;
  waydroid = getExe pkgs.waydroid;
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
        "special:android, on-created-empty:${launch} --workspace special:android --empty ${waydroid} app launch com.YoStarEN.Arknights"
        "special:game, on-created-empty:${steam}"
        "special:music, on-created-empty:${youtube-music}"
        "special:office, on-created-empty:${launch} --workspace special:office --empty --tile -- ${libreoffice}"
        "special:password, on-created-empty:${launch} --workspace special:password --empty ${_1password}"
        "special:terminal, on-created-empty:${ghostty}"
        "special:vm, on-created-empty:${launch} --workspace special:vm --empty ${virt-manager}"
        "special:wallpaper, on-created-empty:${loupe} /tmp/wallpaper.png"
      ];

      # https://wiki.hyprland.org/Configuring/Window-Rules
      #?? windowrulev2 = RULE, WINDOW
      windowrulev2 = with config.custom; let
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
              then 0.5 # 50%
              else 1
            )
            + (
              if ultrawide
              then - gap / 2 * 2 # Center layout padding between windows
              else - gap * 2
            )
            - border * 2
          );
          h = tr (height / scale * 0.5); # 50%
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
          h = tr (height / scale * 0.75); # 75%
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
              then 0.5 # 50%
              else 1
            )
            + (
              if ultrawide
              then - gap / 2 * 2 # Center layout padding between windows
              else - gap * 2
            )
            - border * 2
          );
          h = tr (height
            / scale
            * (
              if ultrawide
              then 0.2 # 20%
              else 0.3 # 30%
            ));
        };

        # Top right
        pip = rec {
          x = tr (width / scale - (toInt w) - gap - border);
          y = tr (gap + border);
          w = tr (width / scale * 0.25 - gap - gap / 2 - border * 2); # 25%
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
        title = expr: rules: merge "title" "^${expr}$" rules;

        ### Pseudo-tags
        # Wrap generated rules in Nix categories
        tag = {
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
            (class "dropdown" rules)
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
          (class ".*" ["float" "suppressevent maximize"])
          (floating false ["noshadow" "plugin:hyprbars:nobar"])
          (floating true ["noborder"])
          (focus false ["plugin:hyprbars:bar_color rgb(073642)" "plugin:hyprbars:title_color rgb(586e75)"])
          (fullscreen true ["idleinhibit focus"])
          (pinned true ["bordercolor rgb(073642) rgb(073642)"])

          (tag.android ["idleinhibit always" "move ${android.x} ${android.y}" "size ${android.w} ${android.h}" "workspace special:android silent" "plugin:hyprbars:nobar"])
          (tag.browser ["tile" "workspace 1"])
          (tag.clipboard ["move ${clipboard.x} ${clipboard.y}" "pin" "size ${clipboard.w} ${clipboard.h}" "stayfocused" "plugin:hyprbars:nobar"])
          (tag.dropdown ["move ${dropdown.x} ${dropdown.y}" "pin" "size ${dropdown.w} ${dropdown.h}" "plugin:hyprbars:nobar"])
          (tag.editor ["tile"])
          (tag.files ["center"])
          (tag.game ["focusonactivate" "idleinhibit always" "noborder" "noshadow" "renderunfocused" "workspace name:game" "plugin:hyprbars:nobar"])
          (tag.media ["center" "keepaspectratio" "size <90% <90%"])
          (tag.music ["tile" "workspace special:music silent"])
          (tag.office ["tile" "workspace special:office silent"])
          (tag.password ["center" "tile" "workspace special:password silent" "plugin:hyprbars:nobar"])
          (tag.pip ["keepaspectratio" "move ${pip.x} ${pip.y}" "noinitialfocus" "pin" "size ${pip.w} ${pip.h}" "plugin:hyprbars:nobar"])
          (tag.social ["tile"])
          (tag.steam ["suppressevent activate activatefocus" "workspace special:steam silent" "plugin:hyprbars:nobar"])
          (tag.terminal ["tile"])
          (tag.vm ["workspace special:vm silent"])

          ### Overrides
          (class "dev\\.benz\\.walker" ["noanim" "noshadow" "pin" "stayfocused" "plugin:hyprbars:nobar"]) # Imitate layer
          (class "org\\.gnome\\.NautilusPreviewer" ["stayfocused" "plugin:hyprbars:nobar"]) # Sushi
          (class "signal" ["tile"]) # Initial window in social group
          (class "steam_app_1473350" ["workspace 0"]) # (the) Gnorp Apologue
          (class "Tap Wizard 2\\.x86_64" ["workspace 0"])
          (class "Xdg-desktop-portal-gtk" ["noborder" "noshadow" "plugin:hyprbars:nobar"])

          (title "File Upload" ["center" "float" "size 1000 625"])
          (title "Open" ["center" "float" "size 1000 625"])
          (title "Save As" ["center" "float" "size 1000 625"])

          #!! Expressions are not wrapped in ^$
          (fields {
            class = "^com\\.github\\.wwmm\\.easyeffects$";
            title = "^Easy Effects$"; # Main window
          } ["center" "float" "size 50% 50%"])
          (fields {
            class = "^discord$";
            title = "^Discord Updater$"; # Update dialog
          } ["float" "nofocus" "plugin:hyprbars:nobar"])
          (fields {
            class = "^lutris$";
            title = "^Lutris$"; # Main window
          } ["center" "float" "size 1000 500"])
          (fields {
            class = "^org\\.gnome\\.Loupe$";
            title = "^wallpaper.png$";
          } ["tile" "workspace special:wallpaper silent"])
          (fields {
            class = "^org\\.gnome\\.Nautilus$";
            title = "^Home$"; # Main window
          } ["size 1000 625"])
          (fields {
            class = "^org\\.gnome\\.Nautilus$";
            title = "^New Folder$";
          } ["plugin:hyprbars:nobar"])
          (fields {
            class = "^org\\.remmina\\.Remmina$";
            title = "^Remmina.*$"; # Main windows
          } ["center" "float" "size 1000 500"])
          (fields {
            class = "^steam$";
            title = "^notificationtoasts$"; # Steam notifications
          } ["float" "nofocus" "pin"])
          (fields {
            class = "^steam$";
            title = "^Steam$"; # Main window
          } ["tile"])
          (fields {
            class = "^virt-manager$";
            title = "^.+on QEMU/KVM$"; # VM window
          } ["tile"])
        ];
    };
  };
}
