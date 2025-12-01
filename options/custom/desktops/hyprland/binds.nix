{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland.binds;
  hm = config.home-manager.users.${config.custom.username};

  audio = hm.home.file.".local/bin/audio".source;
  cat = getExe' pkgs.coreutils "cat";
  codium = getExe hm.programs.vscode.package;
  ghostty = getExe hm.programs.ghostty.package;
  gnome-text-editor = getExe pkgs.gnome-text-editor;
  hyprctl = getExe' config.programs.hyprland.package "hyprctl";
  hyprlock = getExe hm.programs.hyprlock.package;
  hyprpicker = getExe pkgs.hyprpicker;
  inhibit = hm.home.file.".local/bin/inhibit".source;
  left = hm.home.file.".local/bin/left".source;
  loginctl = getExe' pkgs.systemd "loginctl";
  nautilus = getExe pkgs.nautilus;
  notify-send = getExe pkgs.libnotify;
  obsidian = getExe pkgs.obsidian;
  pkill = getExe' pkgs.procps "pkill";
  playerctl = getExe pkgs.playerctl;
  power = hm.home.file.".local/bin/power".source;
  remote = hm.home.file.".local/bin/remote".source;
  screenshot = hm.home.file.".local/bin/screenshot".source;
  sleep = getExe' pkgs.coreutils "sleep";
  steam = getExe config.programs.steam.package;
  swayosd-client = getExe' pkgs.swayosd "swayosd-client";
  toggle = hm.home.file.".local/bin/toggle".source;
  uwsm = getExe pkgs.uwsm;
  virt-manager = getExe config.programs.virt-manager.package;
  vrr = hm.home.file.".local/bin/vrr".source;
  waydroid = getExe pkgs.waydroid;
  window = hm.home.file.".local/bin/window".source;
  zeditor = getExe hm.programs.zed-editor.package;
  zoom = hm.home.file.".local/bin/zoom".source;

  command = command: "${uwsm} app -- ${command}";
in {
  options.custom.desktops.hyprland.binds = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland.settings = let
          # Reverse mods and key for alphabetical sorting
          #?? key <"KEY"> <"MODS"|null> <"DISPATCHER"> <"PARAMS"|null>
          key = key: mods: dispatcher: params: "${
            if (isNull mods)
            then ""
            else mods
          }, ${key}, ${dispatcher}${
            if (isNull params)
            then ""
            else ", ${
              if dispatcher == "exec"
              then command params
              else params
            }"
          }";

          dropdown = concatStringsSep " " [
            "${toggle}"
            "--focus"
            "--type class"
            "--expression '^.*dropdown$'"
            "--workspace special:dropdown"
            "--"

            #!! Must be valid GTK class
            # https://github.com/ghostty-org/ghostty/issues/3336
            "${ghostty} --class=gtk.dropdown"
          ];

          pip-switch = with config.custom;
            concatStringsSep " " [
              "${window} move"
              "--current"
              "--property title"
              "'^Picture.in.[Pp]icture$'"
              "${toString (gap + border)},${toString (gap + border)}"
            ];

          pip-toggle = concatStringsSep " " [
            "${toggle}"
            "--type title"
            "--expression '^Picture.in.[Pp]icture$'"
            "--workspace special:pip"
          ];

          vm = ''${remote} --vm --client xfreerdp --username Myned --password "$(${cat} ${config.age.secrets."${config.custom.hostname}/vm/myndows.pass".path})" ${
              if config.custom.hidpi
              then "--scale 140"
              else ""
            } myndows'';
        in {
          # https://wiki.hyprland.org/Configuring/Binds
          #?? bind = MODS, KEY, DISPATCHER, [PARAMS]
          #?? wev

          # Regular binds
          bind = [];

          # Repeat binds
          binde = [
            # Media keys
            # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
            (key "XF86AudioMute" null "exec" "${swayosd-client} --output-volume mute-toggle") # F1
            (key "XF86AudioLowerVolume" null "exec" "${swayosd-client} --output-volume lower") # F2
            (key "XF86AudioRaiseVolume" null "exec" "${swayosd-client} --output-volume raise") # F3
            (key "XF86AudioPrev" null "exec" "${playerctl} previous") # F4
            (key "XF86AudioPlay" null "exec" "${playerctl} play-pause") # F5
            (key "XF86AudioNext" null "exec" "${playerctl} next") # F6
            (key "XF86MonBrightnessDown" null "exec" "${swayosd-client} --brightness lower") # F7
            (key "XF86MonBrightnessUp" null "exec" "${swayosd-client} --brightness raise") # F8
            (key "XF86AudioMedia" null "exec" "${notify-send} test") # F12

            # Meta alternatives
            (key "0" "Super" "exec" "${swayosd-client} --output-volume mute-toggle")
            (key "Minus" "Super" "exec" "${swayosd-client} --output-volume lower")
            (key "Equal" "Super" "exec" "${swayosd-client} --output-volume raise")
            (key "Left" "Super" "exec" "${playerctl} previous")
            (key "Delete" "Super" "exec" "${playerctl} play-pause")
            (key "Right" "Super" "exec" "${playerctl} next")
            (key "Down" "Super" "exec" "${swayosd-client} --brightness lower")
            (key "Up" "Super" "exec" "${swayosd-client} --brightness raise")

            # Special keys
            (key "Apostrophe" "Super" "exec" "${screenshot} selection")
            (key "Apostrophe" "Super+Alt" "exec" "${screenshot} selection --edit")
            (key "Apostrophe" "Super+Alt+Shift" "exec" "${screenshot} display --edit")
            (key "Apostrophe" "Super+Shift" "exec" "${screenshot} display")
            (key "Backslash" "Super+Shift" "exec" power)
            (key "Backspace" "Super" "scroller:alignwindow" "middle")
            (key "Backspace" "Super+Shift" "scroller:fitsize" "visible")
            (key "Equal" "Super+Shift" "exec" "${zoom} +0.1")
            (key "Escape" "Super" "pin" null)
            (key "Escape" "Super+Alt" "exec" "lifx state --color red")
            (key "Escape" "Super+Shift" "togglefloating" null)
            (key "Left" "Super+Ctrl+Shift" "exec" "${left} --scroll kensington-orbit-wireless-tb-mouse")
            (key "Minus" "Super+Shift" "exec" "${zoom} -0.1")
            (key "Return" "Super" "fullscreen" "1") # Maximize
            (key "Return" "Super+Shift" "fullscreen" "0") # Fullscreen
            (key "Slash" "Super" "exec" vrr)
            (key "Space" "Ctrl" "exec" dropdown)
            (key "Space" "Ctrl+Alt" "exec" "lifx toggle")
            (key "Space" "Ctrl+Shift" "exec" pip-toggle)
            (key "Space" "Super" "togglespecialworkspace" "scratchpad")
            (key "Space" "Super+Ctrl+Shift" "exec" pip-switch)
            (key "Space" "Super+Shift" "movetoworkspacesilent" "special:scratchpad")
            (key "Tab" "Super" "scroller:toggleoverview" null)

            # Alphanumeric keys
            (key "0" "Super+Shift" "exec" zoom)
            (key "1" "Ctrl+Alt" "exec" "lifx state --brightness 0.01")
            (key "1" "Super" "workspace" "1")
            (key "1" "Super+Alt" "exec" "lifx state --kelvin 1500")
            (key "1" "Super+Shift" "movetoworkspacesilent" "1")
            (key "2" "Ctrl+Alt" "exec" "lifx state --brightness 0.25")
            (key "2" "Super" "workspace" "2")
            (key "2" "Super+Alt" "exec" "lifx state --kelvin 2500")
            (key "2" "Super+Shift" "movetoworkspacesilent" "2")
            (key "3" "Ctrl+Alt" "exec" "lifx state --brightness 0.50")
            (key "3" "Super" "workspace" "3")
            (key "3" "Super+Alt" "exec" "lifx state --kelvin 3000")
            (key "3" "Super+Shift" "movetoworkspacesilent" "3")
            (key "4" "Ctrl+Alt" "exec" "lifx state --brightness 0.75")
            (key "4" "Super" "workspace" "4")
            (key "4" "Super+Alt" "exec" "lifx state --kelvin 4000")
            (key "4" "Super+Shift" "movetoworkspacesilent" "4")
            (key "5" "Ctrl+Alt" "exec" "lifx state --brightness 1.00")
            (key "5" "Super" "workspace" "5")
            (key "5" "Super+Alt" "exec" "lifx state --kelvin 5000")
            (key "5" "Super+Shift" "movetoworkspacesilent" "5")
            (key "6" "Super" "workspace" "6")
            (key "6" "Super+Shift" "movetoworkspacesilent" "6")
            (key "7" "Super" "workspace" "7")
            (key "7" "Super+Shift" "movetoworkspacesilent" "7")
            (key "8" "Super" "workspace" "8")
            (key "8" "Super+Shift" "movetoworkspacesilent" "8")
            (key "9" "Super" "exec" audio)
            (key "A" "Ctrl+Alt" "exec" "${waydroid} session stop")
            (key "A" "Super" "scroller:movefocus" "l")
            (key "A" "Super+Ctrl" "scroller:alignwindow" "left")
            (key "A" "Super+Shift" "scroller:movewindow" "l")
            (key "B" "Super" "exec" config.custom.browser.command)
            (key "C" "Super" "exec" config.custom.menus.clipboard.show)
            (key "C" "Super+Shift" "exec" config.custom.menus.clipboard.clear)
            (key "D" "Super" "togglespecialworkspace" "android")
            (key "D" "Super+Shift" "movetoworkspacesilent" "special:android")
            (key "E" "Super" "exec" "${gnome-text-editor} --new-window")
            (key "F" "Super" "exec" "${nautilus} --new-window")
            (key "G" "Super" "togglespecialworkspace" "game")
            (key "G" "Super+Ctrl" "exec" steam)
            (key "G" "Super+Shift" "movetoworkspacesilent" "special:game")
            (key "I" "Super" "exec" zeditor)
            (key "K" "Super" "exec" obsidian)
            (key "M" "Super" "togglespecialworkspace" "music")
            (key "M" "Super+Shift" "movetoworkspacesilent" "special:music")
            (key "O" "Super" "exec" "${hyprpicker} --autocopy")
            (key "O" "Super+Shift" "exec" "${hyprpicker} --autocopy --format rgb")
            (key "P" "Ctrl+Alt" "exec" "${pkill} --exact bitwarden-desktop")
            (key "P" "Super" "togglespecialworkspace" "password")
            (key "P" "Super+Shift" "movetoworkspacesilent" "special:password")
            (key "Q" "Ctrl+Alt" "exec" "${hyprctl} kill")
            (key "Q" "Super" "killactive" null)
            (key "R" "Super" "scroller:movefocus" "d")
            (key "R" "Super+Ctrl" "scroller:alignwindow" "down")
            (key "R" "Super+Shift" "scroller:movewindow" "d")
            (key "S" "Ctrl+Alt" "exec" "${pkill} --exact steam")
            (key "S" "Super" "scroller:movefocus" "r")
            (key "S" "Super+Ctrl" "scroller:alignwindow" "right")
            (key "S" "Super+Shift" "scroller:movewindow" "r")
            (key "T" "Ctrl+Alt" "exec" "${pkill} --exact ghostty")
            (key "T" "Super" "togglespecialworkspace" "terminal")
            (key "T" "Super+Ctrl" "exec" ghostty)
            (key "T" "Super+Shift" "movetoworkspacesilent" "special:terminal")
            (key "V" "Super" "togglespecialworkspace" "vm")
            (key "V" "Super+Ctrl" "exec" vm)
            (key "V" "Super+Ctrl+Shift" "exec" virt-manager)
            (key "V" "Super+Shift" "movetoworkspacesilent" "special:vm")
            (key "W" "Super" "scroller:movefocus" "u")
            (key "W" "Super+Ctrl" "scroller:alignwindow" "up")
            (key "W" "Super+Shift" "scroller:movewindow" "u")
            (key "X" "Super" "scroller:cyclewidth" "next")
            (key "X" "Super+Shift" "scroller:cycleheight" "next")
            (key "Z" "Super" "scroller:cyclewidth" "previous")
            (key "Z" "Super+Shift" "scroller:cycleheight" "previous")
          ];

          # Lockscreen binds
          bindl = [
            (key "Delete" "Ctrl" "exec" "${hyprctl} reload")
            (key "Delete" "Ctrl+Alt" "exec" "${loginctl} terminate-user ''") # Current user sessions
            (key "Delete" "Super" "exec" inhibit)
            (key "L" "Super" "exec" "${hyprlock} --immediate & ${sleep} 1 && ${hyprctl} dispatch dpms off")

            # Laptop lid switches
            # https://wiki.hyprland.org/Configuring/Binds/#switches
            #?? hyprctl devices
            #// (key "switch:off:Lid Switch" null "dpms" "on") # Open
            #// (key "switch:on:Lid Switch" null "dpms" "off") # Close
          ];

          # Mouse binds
          bindm = [
            (key "mouse:272" "Super" "movewindow" null) # LMB
            (key "mouse:273" "Super" "resizewindow" null) # RMB
          ];

          # Release binds
          bindr = [
            (key "Alt_L" "Super+Alt" "togglespecialworkspace" "wallpaper")
            (key "Alt_L" "Super+Alt+Shift" "movetoworkspacesilent" "special:wallpaper")
            (key "Control_L" "Super+Ctrl" "scroller:admitwindow" null)
            (key "Control_L" "Super+Ctrl+Shift" "scroller:expelwindow" null)

            # BUG: Causes Hyprland to crash when floating the scroller:pin window
            (key "Shift_L" "Super+Shift" "scroller:pin" null)

            (key "Super_L" "Super" "exec" config.custom.menus.default.show)
            (key "Super_L" "Super+Alt" "exec" config.custom.menus.vault.show)
            (key "Super_L" "Super+Ctrl" "exec" config.custom.menus.calculator.show)
            (key "Super_L" "Super+Ctrl+Shift" "exec" config.custom.menus.network.show)
            (key "Super_L" "Super+Shift" "exec" config.custom.menus.search.show)
          ];
        };
      }
    ];
  };
}
