{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  clipse = "${pkgs.clipse}/bin/clipse";
  codium = "${config.home-manager.users.${config.custom.username}.programs.vscode.package}/bin/codium";
  firefox-esr = "${config.home-manager.users.${config.custom.username}.programs.firefox.finalPackage}/bin/firefox-esr";
  gnome-text-editor = "${pkgs.gnome-text-editor}/bin/gnome-text-editor";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hyprlock = "${config.home-manager.users.${config.custom.username}.programs.hyprlock.package}/bin/hyprlock";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  jq = "${pkgs.jq}/bin/jq";
  kill = "${pkgs.procps}/bin/kill";
  kitty = "${config.home-manager.users.${config.custom.username}.programs.kitty.package}/bin/kitty";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  networkmanager_dmenu = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  obsidian = "${pkgs.obsidian}/bin/obsidian";
  onlyoffice = "${pkgs.onlyoffice-bin}/bin/onlyoffice-desktopeditors";
  pkill = "${pkgs.procps}/bin/pkill";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";
  sleep = "${pkgs.coreutils}/bin/sleep";
  steam = "${config.programs.steam.package}/bin/steam";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  virt-manager = "${config.programs.virt-manager.package}/bin/virt-manager";
  waydroid = "${pkgs.waydroid}/bin/waydroid";
  wofi = "${config.home-manager.users.${config.custom.username}.programs.wofi.package}/bin/wofi";

  cfg = config.custom.desktops.hyprland.binds;
in {
  options.custom.desktops.hyprland.binds.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
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
        else ", ${params}"
      }";
    in {
      # https://wiki.hyprland.org/Configuring/Binds
      #?? bind = MODS, KEY, DISPATCHER, [PARAMS]
      #?? wev

      # Lockscreen binds
      bindl = [
        (key "Delete" "Ctrl" "exec" "${hyprctl} reload")
        (key "Delete" "Ctrl+Alt" "exec" "${loginctl} terminate-session ''")
        (key "Delete" "Super" "exec" "inhibit")
        (key "L" "Super" "exec" "${hyprlock} --immediate & ${sleep} 1 && ${hyprctl} dispatch dpms off")

        # Laptop lid switches
        # https://wiki.hyprland.org/Configuring/Binds/#switches
        #?? hyprctl devices
        (key "switch:off:Lid Switch" null "dpms" "on") # Open
        (key "switch:on:Lid Switch" null "dpms" "off") # Close
      ];

      # Mouse binds
      bindm = [
        (key "mouse:272" "Super" "movewindow" null) # LMB
        (key "mouse:273" "Super" "resizewindow" null) # RMB
      ];

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
      ];

      # Release binds
      bindr = [
        (key "Alt_L" "Super+Alt" "togglespecialworkspace" "wallpaper")
        (key "Alt_L" "Super+Alt+Shift" "movetoworkspacesilent" "special:wallpaper")
        (key "Control_L" "Super+Ctrl" "layoutmsg" "swapwithmaster master")
        (key "Control_L" "Super+Ctrl+Alt+Shift" "layoutmsg" "removemaster")
        (key "Control_L" "Super+Ctrl+Shift" "layoutmsg" "addmaster")
        (key "Shift_L" "Super+Shift" "workspace" "previous")
        (key "Super_L" "Super" "exec" "${pkill} wofi || ${wofi} --show drun")
        (key "Super_L" "Super+Alt" "exec" "${pkill} wofi || ${rofi-rbw}")
        (key "Super_L" "Super+Ctrl" "exec" "${pkill} wofi || calc")
        (key "Super_L" "Super+Ctrl+Shift" "exec" "${pkill} wofi || ${networkmanager_dmenu}")
        (key "Super_L" "Super+Shift" "exec" "${pkill} wofi || ${wofi} --show run")
      ];

      # Regular binds
      bind = [
        (key "mouse:274" "Super" "layoutmsg" "swapwithmaster master")
        (key "mouse:274" "Super+Shift" "layoutmsg" "addmaster")
        (key "mouse:274" "Super+Ctrl+Shift" "layoutmsg" "removemaster")

        (key "Backslash" "Super" "layoutmsg" "orientationcenter")
        (key "Backslash" "Super+Shift" "splitratio" "exact 0.5") # Reset layout ratio
        (key "Backspace" "Super" "changegroupactive" "f")
        (key "Backspace" "Super+Ctrl" "togglegroup" null)
        (key "Backspace" "Super+Ctrl+Shift" "lockactivegroup" "toggle")
        (key "Backspace" "Super+Shift" "movegroupwindow" null)
        (key "Bracketleft" "Super" "layoutmsg" "orientationprev")
        (key "Bracketleft" "Super+Shift" "splitratio" "-0.1")
        (key "Bracketright" "Super" "layoutmsg" "orientationnext")
        (key "Bracketright" "Super+Shift" "splitratio" "+0.1")

        # TODO: Toggle trackball hand
        #// (key "Delete" "Super" "exec" "left")

        (key "Delete" "Super+Shift" "exec" "vrr")
        (key "Down" "Super" "movewindow" "d")
        (key "Down" "Super+Shift" "movewindoworgroup" "d")
        (key "Equal" "Super" "exec" "audio Normalizer")
        (key "Escape" "Super" "togglefloating" null)
        (key "Escape" "Super+Alt" "exec" "lifx state --color red")
        (key "Escape" "Super+Shift" "centerwindow" null)
        (key "Left" "Super" "movewindow" "l")
        (key "Left" "Super+Shift" "movewindoworgroup" "l")
        (key "Minus" "Super" "exec" "audio")
        (key "Print" "Shift" "exec" "screenshot -d")
        (key "Print" "Super" "exec" "screenshot -e")
        (key "Print" "Super+Shift" "exec" "screenshot -ed")
        (key "Print" null "exec" "screenshot")
        (key "Return" "Super" "fullscreen" "1") # Maximize
        (key "Return" "Super+Shift" "fullscreen" "0") # Fullscreen
        (key "Right" "Super" "movewindow" "r")
        (key "Right" "Super+Shift" "movewindoworgroup" "r")
        (key "Space" "Ctrl" "exec" (concatStringsSep " " [
          "toggle"
          "--focus"
          "--type class"
          "--expression '^dropdown$'"
          "--workspace special:dropdown"
          "--"
          "${kitty} --app-id dropdown --override font_size=12"
        ]))
        (key "Space" "Ctrl+Alt" "exec" "lifx toggle")
        (key "Space" "Ctrl+Shift" "exec" (concatStringsSep " " [
          "toggle"
          "--type title"
          "--expression '^Picture.in.[Pp]icture$'"
          "--workspace special:pip"
        ]))
        (key "Space" "Super" "togglespecialworkspace" "scratchpad")
        (key "Space" "Super+Shift" "movetoworkspacesilent" "special:scratchpad")
        (key "Tab" "Super" "cyclenext" "tiled")
        (key "Tab" "Super+Shift" "alterzorder" "top")
        (key "Tab" "Super+Shift" "cyclenext" "floating")
        (key "Up" "Super" "movewindow" "u")
        (key "Up" "Super+Shift" "movewindoworgroup" "u")

        (key "0" "Super" "workspace" "10")
        (key "0" "Super+Shift" "movetoworkspacesilent" "10")
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
        (key "9" "Super" "workspace" "9")
        (key "9" "Super+Shift" "movetoworkspacesilent" "9")
        (key "A" "Ctrl+Alt" "exec" "${waydroid} session stop")
        (key "A" "Super" "togglespecialworkspace" "android")
        (key "A" "Super+Shift" "movetoworkspacesilent" "android")
        (key "B" "Super" "exec" "[group new lock; tile] ${firefox-esr}")
        (key "C" "Super" "exec" codium)
        (key "E" "Super" "exec" gnome-text-editor)
        (key "F" "Super" "exec" nautilus)
        (key "G" "Super" "workspace" "name:game")
        (key "G" "Super+Alt" "workspace" "name:gamescope")
        (key "G" "Super+Ctrl+Alt" "exec" "${pkill} gamescope")
        (key "G" "Super+Shift" "movetoworkspacesilent" "name:game")
        (key "K" "Super" "exec" obsidian)
        (key "M" "Super" "togglespecialworkspace" "music")
        (key "M" "Super+Shift" "movetoworkspacesilent" "music")
        (key "O" "Super" "togglespecialworkspace" "office")
        (key "O" "Super+Ctrl" "exec" "${onlyoffice}")
        (key "O" "Super+Shift" "movetoworkspacesilent" "special:office")
        (key "P" "Super" "exec" "${hyprpicker} --autocopy")
        (key "P" "Super+Shift" "exec" "${hyprpicker} --autocopy --format rgb")
        (key "Q" "Ctrl+Alt" "exec" "${kill} -9 $(${hyprctl} -j activewindow | ${jq} .pid)")
        (key "Q" "Ctrl+Alt+Shift" "exec" "close") # Quit all windows
        (key "Q" "Super" "killactive" null)
        (key "S" "Ctrl+Alt" "exec" "${pkill} steam")
        (key "S" "Super" "togglespecialworkspace" "steam")
        (key "S" "Super+Shift" "movetoworkspacesilent" "steam")
        (key "S" "Super+Shift" "exec" steam)
        (key "T" "Ctrl+Alt" "exec" "${pkill} kitty")
        (key "T" "Super" "togglespecialworkspace" "terminal")
        (key "T" "Super+Shift" "movetoworkspacesilent" "terminal")
        (key "T" "Super+Shift" "exec" kitty)
        (key "V" "Super" "exec" "${kitty} --app-id clipboard --override font_size=12 ${clipse}")
        (key "V" "Super+Shift" "exec" "${clipse} -clear && ${notify-send} clipse 'Clipboard cleared' --urgency low")
        (key "W" "Super" "togglespecialworkspace" "vm")
        (key "W" "Super+Ctrl" "exec" "vm -x ${
          if config.custom.hidpi
          then "/scale:140 +f"
          else ""
        }")
        (key "W" "Super+Ctrl+Shift" "exec" "vm ${virt-manager} --show-domain-console myndows")
        (key "W" "Super+Shift" "movetoworkspacesilent" "vm")
        (key "X" "Super" "workspace" "+1")
        (key "X" "Super+Shift" "movetoworkspacesilent" "+1")
        (key "Z" "Super" "workspace" "-1")
        (key "Z" "Super+Shift" "movetoworkspacesilent" "-1")
      ];
    };
  };
}
