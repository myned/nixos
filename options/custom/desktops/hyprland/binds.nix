{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

with lib;

let
  clipse = "${pkgs.clipse}/bin/clipse";
  codium = "${
    config.home-manager.users.${config.custom.username}.programs.vscode.package
  }/bin/codium";
  firefox-esr = "${
    config.home-manager.users.${config.custom.username}.programs.firefox.finalPackage
  }/bin/firefox-esr";
  gnome-text-editor = "${pkgs.gnome-text-editor}/bin/gnome-text-editor";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hyprlock = "${
    config.home-manager.users.${config.custom.username}.programs.hyprlock.package
  }/bin/hyprlock";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  jq = "${pkgs.jq}/bin/jq";
  kill = "${pkgs.procps}/bin/kill";
  kitty = "${config.home-manager.users.${config.custom.username}.programs.kitty.package}/bin/kitty";
  libreoffice = "${config.custom.programs.libreoffice.package}/bin/libreoffice";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  networkmanager_dmenu = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  obsidian = "${pkgs.obsidian}/bin/obsidian";
  pkill = "${pkgs.procps}/bin/pkill";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";
  sleep = "${pkgs.coreutils}/bin/sleep";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  virt-manager = "${config.programs.virt-manager.package}/bin/virt-manager";
  waydroid = "${pkgs.waydroid}/bin/waydroid";
  wofi = "${config.home-manager.users.${config.custom.username}.programs.wofi.package}/bin/wofi";

  cfg = config.custom.desktops.hyprland.binds;
in
{
  options.custom.desktops.hyprland.binds.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # https://wiki.hyprland.org/Configuring/Binds
      #?? bind = MODS, KEY, DISPATCHER, [PARAMS]
      #?? wev
      binds = {
        allow_workspace_cycles = true;
        disable_keybind_grabbing = true;
        scroll_event_delay = 0;
      };

      # Lockscreen binds
      bindl = [
        ### System
        "CTRL, Delete, exec, ${hyprctl} reload"
        "CTRL+ALT, Delete, exec, ${loginctl} terminate-session ''"
        "SUPER, L, exec, ${hyprlock} --immediate & ${sleep} 1 && ${hyprctl} dispatch dpms off"

        ### Scripts
        "SUPER, Delete, exec, inhibit"
      ];

      # Mouse binds
      bindm = [
        "SUPER, mouse:272, movewindow" # LMB
        "SUPER, mouse:273, resizewindow" # RMB
      ];

      # Repeat binds
      binde = [
        # Media keys
        # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
        ", XF86AudioMute, exec, ${swayosd-client} --output-volume mute-toggle"
        ", XF86AudioLowerVolume, exec, ${swayosd-client} --output-volume lower"
        ", XF86AudioRaiseVolume, exec, ${swayosd-client} --output-volume raise"
        ", XF86AudioPlay, exec, ${playerctl} play-pause"
        ", XF86AudioPrev, exec, ${playerctl} previous"
        ", XF86AudioNext, exec, ${playerctl} next"
        ", XF86MonBrightnessDown, exec, ${swayosd-client} --brightness lower"
        ", XF86MonBrightnessUp, exec, ${swayosd-client} --brightness raise"

        # TODO: Unused media key
        #// ", XF86AudioMedia, exec, null"
      ];

      # Release binds
      bindr = [
        ### Applications
        "SUPER, Super_L, exec, ${pkill} wofi || ${wofi} --show drun"
        "SUPER+CTRL, Super_L, exec, ${pkill} wofi || calc"
        "SUPER+SHIFT, Super_L, exec, ${pkill} wofi || ${wofi} --show run"
        "SUPER+SHIFT+CTRL, Super_L, exec, ${pkill} wofi || ${networkmanager_dmenu}"
        "SUPER+ALT, Super_L, exec, ${pkill} wofi || ${rofi-rbw}"

        ### Layouts
        "SUPER+CTRL, Control_L, layoutmsg, swapwithmaster master"
        "SUPER+SHIFT+CTRL, Control_L, layoutmsg, addmaster"
        "SUPER+SHIFT+CTRL+ALT, Control_L, layoutmsg, removemaster"

        ### Workspaces
        "SUPER+SHIFT, Shift_L, workspace, previous"

        # Special workspaces
        "SUPER+ALT, Alt_L, togglespecialworkspace, wallpaper"
      ];

      # Regular binds
      bind = [
        ### Scripts
        ", Print, exec, screenshot"
        "SHIFT, Print, exec, screenshot -d"
        "SUPER, Print, exec, screenshot -e"
        "SUPER+SHIFT, Print, exec, screenshot -ed"
        "SUPER+SHIFT, Delete, exec, vrr"
        "SUPER, Minus, exec, audio"
        "SUPER, Equal, exec, audio Normalizer"
        "SUPER+SHIFT, W, exec, vm -x ${if config.custom.hidpi then "/scale:140 +f" else ""}"
        "SUPER+SHIFT+CTRL, W, exec, vm ${virt-manager} --connect qemu:///system --show-domain-console myndows"
        "SUPER+SHIFT+CTRL, Q, exec, close" # Quit all windows

        # BUG: Freezes window when toggled
        # https://github.com/hyprwm/Hyprland/issues/7609
        "CTRL, Space, exec, toggle dropdown special:dropdown ${kitty} --app-id dropdown --override font_size=12"

        "CTRL+SHIFT, Space, exec, toggle pip special:pip"

        # TODO: Toggle trackball hand
        #// "SUPER, Delete, exec, left"

        ### Applications
        "SUPER, B, exec, [tag +browser] ${firefox-esr}"
        "SUPER, C, exec, ${codium}"
        "SUPER, E, exec, ${gnome-text-editor}"
        "SUPER, F, exec, ${nautilus}"
        "SUPER, K, exec, ${obsidian}"
        "SUPER, O, exec, ${libreoffice}"
        "SUPER, P, exec, ${hyprpicker} --autocopy"
        "SUPER+SHIFT, P, exec, ${hyprpicker} --autocopy --format rgb"
        "SUPER+SHIFT, T, exec, ${kitty}"
        "SUPER, V, exec, ${kitty} --app-id clipboard --override font_size=12 ${clipse}"
        "SUPER+SHIFT, V, exec, ${clipse} -clear && ${notify-send} clipse 'Clipboard cleared' --urgency low"

        # Kill applications
        "SUPER+SHIFT, A, exec, ${waydroid} session stop"
        "SUPER+SHIFT, S, exec, ${pkill} steam"
        "SUPER+SHIFT+CTRL, G, exec, ${pkill} gamescope"

        # LIFX
        "SUPER+ALT, Escape, exec, lifx state --color red"
        "SUPER+ALT, 1, exec, lifx state --kelvin 1500"
        "SUPER+ALT, 2, exec, lifx state --kelvin 2500"
        "SUPER+ALT, 3, exec, lifx state --kelvin 3000"
        "SUPER+ALT, 4, exec, lifx state --kelvin 4000"
        "SUPER+ALT, 5, exec, lifx state --kelvin 5000"
        "CTRL+ALT, 1, exec, lifx state --brightness 0.01"
        "CTRL+ALT, 2, exec, lifx state --brightness 0.25"
        "CTRL+ALT, 3, exec, lifx state --brightness 0.50"
        "CTRL+ALT, 4, exec, lifx state --brightness 0.75"
        "CTRL+ALT, 5, exec, lifx state --brightness 1.00"
        "CTRL+ALT, Space, exec, lifx toggle"

        ### Windows
        "SUPER, Q, killactive"
        "SUPER+SHIFT, Q, exec, ${kill} -9 $(${hyprctl} -j activewindow | ${jq} .pid)"
        "SUPER, Escape, togglefloating"
        "SUPER+SHIFT, Escape, centerwindow"
        "SUPER, Return, fullscreen, 1" # Maximize
        "SUPER+SHIFT, Return, fullscreen, 0" # Fullscreen
        "SUPER, Tab, cyclenext, tiled"

        # FIXME: Handle hover focus and zorder
        "SUPER+SHIFT, Tab, cyclenext, floating"
        "SUPER+SHIFT, Tab, alterzorder, top"

        ### Groups
        "SUPER, Backspace, changegroupactive, f"
        "SUPER+SHIFT, Backspace, changegroupactive, b"
        "SUPER+CTRL, Backspace, togglegroup"
        "SUPER+SHIFT+CTRL, Backspace, lockactivegroup, toggle"
        "SUPER, Up, movewindoworgroup, u"
        "SUPER, Down, movewindoworgroup, d"
        "SUPER, Left, movewindoworgroup, l"
        "SUPER, Right, movewindoworgroup, r"

        ### Layouts
        "SUPER, mouse:274, layoutmsg, swapwithmaster master"
        "SUPER+SHIFT, mouse:274, layoutmsg, addmaster"
        "SUPER+SHIFT+CTRL, mouse:274, layoutmsg, removemaster"
        "SUPER, Bracketleft, layoutmsg, orientationprev"
        "SUPER, Bracketright, layoutmsg, orientationnext"
        "SUPER, Backslash, layoutmsg, orientationcenter"
        "SUPER+SHIFT, Backslash, splitratio, exact 0.5" # Reset layout ratio
        "SUPER+SHIFT, Bracketleft, splitratio, -0.1"
        "SUPER+SHIFT, Bracketright, splitratio, +0.1"

        ### Workspaces
        "SUPER, 1, workspace, 1"
        "SUPER+SHIFT, 1, movetoworkspacesilent, 1"
        "SUPER, 2, workspace, 2"
        "SUPER+SHIFT, 2, movetoworkspacesilent, 2"
        "SUPER, 3, workspace, 3"
        "SUPER+SHIFT, 3, movetoworkspacesilent, 3"
        "SUPER, 4, workspace, 4"
        "SUPER+SHIFT, 4, movetoworkspacesilent, 4"
        "SUPER, 5, workspace, 5"
        "SUPER+SHIFT, 5, movetoworkspacesilent, 5"
        "SUPER, 6, workspace, 6"
        "SUPER+SHIFT, 6, movetoworkspacesilent, 6"
        "SUPER, 7, workspace, 7"
        "SUPER+SHIFT, 7, movetoworkspacesilent, 7"
        "SUPER, 8, workspace, 8"
        "SUPER+SHIFT, 8, movetoworkspacesilent, 8"
        "SUPER, 9, workspace, 9"
        "SUPER+SHIFT, 9, movetoworkspacesilent, 9"
        "SUPER, 0, workspace, 10"
        "SUPER+SHIFT, 0, movetoworkspacesilent, 10"
        "SUPER, Z, workspace, -1"
        "SUPER+SHIFT, Z, movetoworkspacesilent, -1"
        "SUPER, X, workspace, +1"
        "SUPER+SHIFT, X, movetoworkspacesilent, +1"

        # Named workspaces
        "SUPER, G, workspace, name:game"
        "SUPER+SHIFT, G, movetoworkspacesilent, name:game"
        "SUPER+CTRL, G, workspace, name:gamescope"

        # Special workspaces
        "SUPER, A, togglespecialworkspace, android"
        "SUPER, M, togglespecialworkspace, music"
        "SUPER, S, togglespecialworkspace, steam"
        "SUPER, T, togglespecialworkspace, terminal"
        "SUPER, W, togglespecialworkspace, vm"
        "SUPER, Space, togglespecialworkspace, scratchpad"
        "SUPER+SHIFT, Space, movetoworkspacesilent, special:scratchpad"
      ];
    };
  };
}
