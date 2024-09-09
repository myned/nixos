{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  gamescope = "${config.programs.gamescope.package}/bin/gamescope";
  loupe = "${pkgs.loupe}/bin/loupe";
  steam = "${config.programs.steam.package}/bin/steam";
  virt-manager = "${pkgs.virt-manager}/bin/virt-manager";
  waydroid = "${pkgs.waydroid}/bin/waydroid";
  kitty = "${config.home-manager.users.${config.custom.username}.programs.kitty.package}/bin/kitty";
  youtube-music = "${pkgs.youtube-music}/bin/youtube-music";

  cfg = config.custom.desktops.hyprland.rules;
in
{
  options.custom.desktops.hyprland.rules.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # https://wiki.hyprland.org/Configuring/Workspace-Rules
      #?? workspace = WORKSPACE, RULES
      workspace = [
        "name:gamescope, on-created-empty:MANGOHUD=0 ${gamescope} --fullscreen --steam ${steam}"

        "special:android, on-created-empty:${waydroid} app launch com.YoStarEN.Arknights"
        "special:music, on-created-empty:${youtube-music}"
        "special:steam, on-created-empty:${steam}"
        "special:terminal, on-created-empty:${kitty}"
        "special:wallpaper, on-created-empty:[tile] ${loupe} /tmp/wallpaper.png"
      ];

      # https://wiki.hyprland.org/Configuring/Window-Rules
      #?? windowrulev2 = RULE, WINDOW
      windowrulev2 =
        with config.custom;
        let
          # Return hypr-formatted string, converting booleans into 0/1
          format =
            field: expr:
            "${field}:${
              toString (
                if expr == true then
                  1
                else if expr == false then
                  0
                else
                  expr
              )
            }";

          # Generate hypr-formatted window rules
          #?? merge <FIELD|{FIELDS}> <EXPRESSION> <RULES>
          merge =
            field: expr: rules:
            map (
              rule:
              if builtins.isAttrs field then
                "${rule}, ${lib.concatStringsSep ", " (lib.mapAttrsToList (f: e: format f e) field)}"
              else
                "${rule}, ${format field expr}"
            ) rules;

          class = expr: rules: merge "class" "^${expr}$" rules;
          floating = expr: rules: merge "floating" expr rules;
          fullscreen = expr: rules: merge "fullscreen" expr rules;
          pinned = expr: rules: merge "pinned" expr rules;
          tag = expr: rules: merge "tag" expr rules;
          title = expr: rules: merge "title" "^${expr}$" rules;

          fields = fields: rules: merge fields null rules;

          ### Hardware-dependent rules
          # Convert truncated float to string
          tr = num: toString (builtins.floor num);

          # Bottom center
          clipboard = rec {
            x = tr (width / scale / 2 - (toInt w) / 2);
            y = tr (height / scale - (toInt h) - gap - border - padding);
            w = "600";
            h = tr (height / scale * 0.5 * scale);
          };

          # Bottom center
          dropdown = rec {
            x = tr (width / scale / 2 - (toInt w) / 2);
            y = tr (height / scale - (toInt h) - gap - border - padding);
            w = tr (width / scale * (if ultrawide then 0.5 else 1) - gap - gap / 2 + 1);
            h = tr (height / scale * 0.2 * scale);
          };

          # Top right
          pip = rec {
            x = tr (width / scale - (toInt w) - gap - border);
            y = tr (gap + border);
            w = tr (width / scale * 0.25 - gap - gap + 1);
            h = tr ((toInt w) * 9 / 16); # 16:9 aspect ratio
          };
        in
        flatten [
          ### Defaults
          (class ".*" [
            "center"
            "float"
            "suppressevent maximize"
            "syncfullscreen"
          ])
          (floating true [
            "bordercolor rgb(073642)"
            "workspace special:scratchpad"
          ])
          (fullscreen true [ "idleinhibit focus" ])
          (pinned true [ "bordercolor rgb(073642) rgb(073642)" ])

          # TODO: Convert to nix variables instead of tags
          ### Tags
          (tag "android" [
            "tile"
            "workspace special:android"
          ])
          (tag "browser" [
            "group new lock"
            "tile"
            "workspace unset"
          ])
          (tag "clipboard" [
            "move ${clipboard.x} ${clipboard.y}"
            "pin"
            "size ${clipboard.w} ${clipboard.h}"
            "stayfocused"
          ])
          (tag "dropdown" [
            "move ${dropdown.x} ${dropdown.y}"
            "pin"
            "size ${dropdown.w} ${dropdown.h}"
            "workspace special:dropdown"
          ])
          (tag "editor" [
            "group invade"
            "tile"
            "workspace unset"
          ])
          (tag "files" [
            "size 1000 625"
          ])
          (tag "game" [
            "group barred"
            "idleinhibit always"
            "noborder"
            "noshadow"
            "renderunfocused"
            "workspace name:game"
          ])
          (tag "music" [
            "tile"
            "workspace special:music"
          ])
          (tag "pip" [
            "keepaspectratio"
            "move ${pip.x} ${pip.y}"
            "pin"
            "size ${pip.w} ${pip.h}"
          ])
          (tag "social" [
            "group"
            "tile"
            "workspace unset"
          ])
          (tag "steam" [ "workspace special:steam" ])
          (tag "terminal" [
            "tile"
            "workspace unset"
          ])
          (tag "vm" [ "workspace special:vm" ])
          (tag "wine" [
            "noborder"
            "noshadow"
          ])

          ### Applications
          (class ".*\\.(exe|x86_64)" [ "tag +wine" ]) # Wine
          (class "(sdl-|wl|x)freerdp" [
            "nomaxsize"
            "tag +vm"
            "tile"
          ])
          (class "cinny" [ "tag +social" ])
          (class "clipboard" [ "tag +clipboard" ])
          (class "codium-url-handler" [ "tag +editor" ]) # VSCode
          (class "discord" [ "tag +social" ])
          (class "dropdown" [ "tag +dropdown" ])
          (class "Element" [ "tag +social" ])
          (class "foot" [ "tag +terminal" ])
          (class "kitty" [ "tag +terminal" ])
          (class "libreoffice.+" [
            "tile"
            "workspace unset"
          ])
          (class "moe\\.launcher\\.the-honkers-railway-launcher" [
            "size 1280 730"
            "tag +game"
          ])
          (class "obsidian" [
            "group barred"
            "tag +editor"
          ])
          (class "org\\.gnome\\.Nautilus" [ "tag +files" ])
          (class "org\\.telegram\\.desktop" [ "tag +social" ])
          (class "org\\.wezfurlong\\.wezterm" [ "tag +terminal" ])
          (class "SDL Application" [ "tag +steam" ]) # Steam
          (class "Spotify" [ "tag +music" ])
          (class "steam_app_1473350" [ "workspace 0" ]) # (the) Gnorp Apologue
          (class "steam" [ "tag +steam" ])
          (class "steam_app_.+" [ "tag +game" ]) # Proton
          (class "Tap Wizard 2.x86_64" [ "workspace 0" ])
          (class "virt-manager" [ "tag +vm" ])
          (class "waydroid.*" [ "tag +android" ])
          (class "YouTube Music" [ "tag +music" ])

          (title "Picture.in.[Pp]icture" [ "tag +pip" ])
          (title "Spotify Premium" [ "tag +music" ])

          ### Overrides
          #!! Expressions are not wrapped in ^$
          (fields
            {
              class = "^lutris$";
              title = "^Lutris$";
            }
            [
              "center"
              "size 1000 500"
            ]
          )
          (fields {
            tag = "steam";
            title = "^notificationtoasts$";
          } [ "workspace unset" ])
          (fields {
            tag = "steam";
            title = "^Steam$";
          } [ "tile" ])

          (fields
            {
              class = "^com\\.github\\.wwmm\\.easyeffects$";
              title = "^Easy Effects$";
            }
            [
              "size 50% 50%"
            ]
          )
          (fields
            {
              class = "^discord$";
              title = "^Discord Updater$";
            }
            [
              "float"
              "nofocus"
            ]
          )
          (fields {
            class = "^virt-manager$";
            title = "^.+on QEMU/KVM$";
          } [ "tile" ])
        ];
    };
  };
}
