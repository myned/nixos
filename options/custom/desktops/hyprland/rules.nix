{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  _1password = "${config.programs._1password-gui.package}/bin/1password";
  gamescope = "${config.programs.gamescope.package}/bin/gamescope";
  hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";
  kitty = "${config.home-manager.users.${config.custom.username}.programs.kitty.package}/bin/kitty";
  launch = config.home-manager.users.${config.custom.username}.home.file.".local/bin/launch".source;
  loupe = "${pkgs.loupe}/bin/loupe";
  onlyoffice-desktopeditors = "${pkgs.onlyoffice-bin}/bin/onlyoffice-desktopeditors --system-title-bar --xdg-desktop-portal";
  pgrep = "${pkgs.procps}/bin/pgrep";
  steam = "${config.programs.steam.package}/bin/steam";
  virt-manager = "${pkgs.virt-manager}/bin/virt-manager";
  waydroid = "${pkgs.waydroid}/bin/waydroid";
  youtube-music = "${pkgs.youtube-music}/bin/youtube-music";

  cfg = config.custom.desktops.hyprland.rules;
in {
  options.custom.desktops.hyprland.rules.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # BUG: on-created-empty race condition with delayed windows
      # https://github.com/hyprwm/Hyprland/issues/5663
      # https://wiki.hyprland.org/Configuring/Workspace-Rules
      #?? workspace = WORKSPACE, RULES
      workspace = [
        "special:android, on-created-empty:${launch} --workspace special:android --empty ${waydroid} app launch com.YoStarEN.Arknights"
        "special:gamescope, on-created-empty:MANGOHUD=0 ${gamescope} --fullscreen --steam ${steam}"
        "special:music, on-created-empty:${youtube-music}"
        "special:office, on-created-empty:${launch} --workspace special:office --empty --tile -- ${onlyoffice-desktopeditors}"
        "special:password, on-created-empty:${launch} --workspace special:password --empty ${_1password}"
        "special:steam, on-created-empty:${steam}"
        "special:terminal, on-created-empty:${kitty}"
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
              if builtins.isAttrs field
              then "${rule}, ${lib.concatStringsSep ", " (lib.mapAttrsToList (f: e: format f e) field)}"
              else "${rule}, ${format field expr}"
          )
          rules;

        class = expr: rules: merge "class" "^${expr}$" rules;
        floating = expr: rules: merge "floating" expr rules;
        fullscreen = expr: rules: merge "fullscreen" expr rules;
        pinned = expr: rules: merge "pinned" expr rules;
        title = expr: rules: merge "title" "^${expr}$" rules;

        fields = fields: rules: merge fields null rules;

        ### Pseudo-tags
        # Wrap generated rules in Nix categories
        tag = {
          android = rules: [
            (class "[Ww]aydroid.*" rules)
          ];
          browser = rules: [
            (fields {
                class = "^chromium-browser$";
                title = "^(?!Picture.in.[Pp]icture).*$";
              }
              rules)
            (fields {
                class = "^firefox$";
                title = "^(?!Picture.in.[Pp]icture).*$";
              }
              rules)
          ];
          clipboard = rules: [
            (class "clipboard" rules)
          ];
          dropdown = rules: [
            (class "dropdown" rules)
          ];
          editor = rules: [
            (class "codium-url-handler" rules) # VSCode
            (class "obsidian" (rules ++ ["group barred"]))
          ];
          files = rules: [
            (class "org\\.gnome\\.Nautilus" rules)
          ];
          game = rules: [
            (class "moe\\.launcher\\.the-honkers-railway-launcher" (rules ++ ["size 1280 730"])) # Honkai: Star Rail
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
            (class "draw\\.io" (rules ++ ["group override set" "tile"]))
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
            (class "kitty" rules)
            (class "org\\.wezfurlong\\.wezterm" rules)
          ];
          vm = rules: [
            (class "(sdl-|wl|x)freerdp" (rules ++ ["nomaxsize" "tile"]))
            (class "virt-manager" rules)
          ];
          wine = rules: [
            (class ".*\\.(exe|x86_64)" rules) # Wine
          ];
        };
      in
        flatten [
          ### Defaults
          (class ".*" ["float" "group barred" "suppressevent maximize"])
          (floating false ["noshadow"])
          (floating true ["noborder"])
          (fullscreen true ["idleinhibit focus"])
          (pinned true ["bordercolor rgb(073642) rgb(073642)"])

          (tag.android ["idleinhibit always" "move ${android.x} ${android.y}" "size ${android.w} ${android.h}" "workspace special:android"])
          (tag.browser ["group override set" "tile" "workspace 1"])
          (tag.clipboard ["move ${clipboard.x} ${clipboard.y}" "pin" "size ${clipboard.w} ${clipboard.h}" "stayfocused"])
          (tag.dropdown ["move ${dropdown.x} ${dropdown.y}" "pin" "size ${dropdown.w} ${dropdown.h}"])
          (tag.editor ["group override set" "tile"])
          (tag.files ["center" "size 1000 625"])
          (tag.game ["fullscreen" "idleinhibit always" "noborder" "noshadow" "renderunfocused" "workspace name:game"])
          (tag.media ["center" "keepaspectratio" "size <90% <90%"])
          (tag.music ["tile" "workspace special:music"])
          (tag.office ["workspace special:office"])
          (tag.password ["center" "tile" "workspace special:password"])
          (tag.pip ["keepaspectratio" "move ${pip.x} ${pip.y}" "noinitialfocus" "pin" "size ${pip.w} ${pip.h}"])
          (tag.social ["group override set" "tile"])
          (tag.steam ["suppressevent activate activatefocus" "workspace special:steam"])
          (tag.terminal ["tile"])
          (tag.vm ["workspace special:vm"])
          (tag.wine ["noborder" "noshadow"])

          ### Overrides
          (class "org\\.gnome\\.NautilusPreviewer" ["stayfocused"]) # Sushi
          (class "signal" ["group override new" "tile"]) # Initial window in social group
          (class "steam_app_1473350" ["workspace 0"]) # (the) Gnorp Apologue
          (class "Tap Wizard 2\\.x86_64" ["workspace 0"])
          (class "Xdg-desktop-portal-gtk" ["noborder" "noshadow"])

          #!! Expressions are not wrapped in ^$
          (fields {
            class = "^com\\.github\\.wwmm\\.easyeffects$";
            title = "^Easy Effects$"; # Main window
          } ["center" "size 50% 50%"])
          (fields {
            class = "^discord$";
            title = "^Discord Updater$"; # Update dialog
          } ["float" "nofocus"])
          (fields {
            class = "^lutris$";
            title = "^Lutris$"; # Main window
          } ["center" "size 1000 500"])
          (fields {
            class = "^org\\.gnome\\.Loupe$";
            title = "^wallpaper.png$";
          } ["tile" "workspace special:wallpaper"])
          (fields {
            class = "^org\\.remmina\\.Remmina$";
            title = "^Remmina Remote Desktop Client$"; # Main window
          } ["center" "size 1000 500"])
          (fields {
            class = "^steam$";
            title = "^notificationtoasts$"; # Steam notifications
          } ["nofocus" "pin"])
          (fields {
            class = "^steam$";
            title = "^Steam$"; # Main window
          } ["tile"])
          (fields {
            class = "^virt-manager$";
            title = "^.+on QEMU/KVM$"; # VM window
          } ["group override set" "tile"])
        ];
    };
  };
}
