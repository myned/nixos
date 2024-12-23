{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  audio = "~/.local/bin/audio";
  cat = "${pkgs.coreutils}/bin/cat";
  clipse = "${pkgs.clipse}/bin/clipse";
  codium = "${config.home-manager.users.${config.custom.username}.programs.vscode.package}/bin/codium";
  gnome-text-editor = "${pkgs.gnome-text-editor}/bin/gnome-text-editor";
  hyprlock = "${config.home-manager.users.${config.custom.username}.programs.hyprlock.package}/bin/hyprlock";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  inhibit = config.home-manager.users.${config.custom.username}.home.file.".local/bin/inhibit".source;
  jq = "${pkgs.jq}/bin/jq";
  kill = "${pkgs.procps}/bin/kill";
  kitty = "${config.home-manager.users.${config.custom.username}.programs.kitty.package}/bin/kitty";
  left = config.home-manager.users.${config.custom.username}.home.file.".local/bin/left".source;
  libreoffice = "${config.custom.programs.libreoffice.package}/bin/libreoffice";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  menu = config.home-manager.users.${config.custom.username}.home.file.".local/bin/menu".source;
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  networkmanager_dmenu = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  niri = "${config.programs.niri.package}/bin/niri";
  obsidian = "${pkgs.obsidian}/bin/obsidian";
  onlyoffice-desktopeditors = "${pkgs.onlyoffice-bin}/bin/onlyoffice-desktopeditors --system-title-bar --xdg-desktop-portal";
  pkill = "${pkgs.procps}/bin/pkill";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  power = config.home-manager.users.${config.custom.username}.home.file.".local/bin/power".source;
  remote = config.home-manager.users.${config.custom.username}.home.file.".local/bin/remote".source;
  rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";
  rm = "${pkgs.coreutils}/bin/rm";
  sleep = "${pkgs.coreutils}/bin/sleep";
  smile = "${pkgs.smile}/bin/smile";
  steam = "${config.programs.steam.package}/bin/steam";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  toggle = "~/.local/bin/toggle";
  virt-manager = "${config.programs.virt-manager.package}/bin/virt-manager";
  vrr = config.home-manager.users.${config.custom.username}.home.file.".local/bin/vrr".source;
  walker = "${config.home-manager.users.${config.custom.username}.programs.walker.package}/bin/walker";
  waydroid = "${pkgs.waydroid}/bin/waydroid";
  window = config.home-manager.users.${config.custom.username}.home.file.".local/bin/window".source;
  workspace = config.home-manager.users.${config.custom.username}.home.file.".local/bin/workspace".source;
  zoom = config.home-manager.users.${config.custom.username}.home.file.".local/bin/zoom".source;

  cfg = config.custom.desktops.niri.binds;
in {
  options.custom.desktops.niri.binds = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/YaLTeR/niri/wiki/Configuration:-Key-Bindings
      #?? Mod = Super/Win, Alt when nested; Mod5 = AltGr
      #?? wev
      programs.niri.settings.binds = let
        # Swap modifiers and key for alphabetical sorting
        #?? (key "KEY" "MODIFIERS" (ACTION "ARGUMENT"))
        key = key: modifiers: action: {
          name = "${
            if (isString modifiers)
            then "${modifiers}+"
            else ""
          }${key}";
          value = {inherit action;};
        };
      in
        listToAttrs (with config.home-manager.users.${config.custom.username}.lib.niri.actions; [
          (key "0" "Mod" (spawn [swayosd-client "--output-volume" "mute-toggle"]))
          (key "A" "Mod" focus-column-or-monitor-left)
          (key "A" "Mod+Shift" move-column-left-or-to-monitor-left)
          (key "Apostrophe" "Mod" screenshot)
          (key "Apostrophe" "Mod+Ctrl+Shift" screenshot-screen)
          (key "Apostrophe" "Mod+Shift" screenshot-window)
          (key "Backslash" "Mod" (spawn inhibit))
          (key "Bracketleft" "Mod" (switch-layout "prev"))
          (key "Bracketright" "Mod" (switch-layout "next"))
          (key "Delete" "Ctrl+Alt" quit)
          (key "Delete" "Mod" (spawn [playerctl] "play-pause"))
          (key "Down" "Mod" (spawn [swayosd-client "--brightness" "lower"]))
          (key "Equal" "Mod" (spawn [swayosd-client "--output-volume" "raise"]))
          (key "L" "Mod+Shift" suspend)
          (key "L" "Mod" (spawn [hyprlock "--immediate" "&" niri "msg" "power-off-monitors"]))
          (key "Left" "Mod" (spawn [playerctl "previous"]))
          (key "Minus" "Mod" (spawn [swayosd-client "--output-volume" "lower"]))
          (key "Q" "Mod" close-window)
          (key "R" "Mod" focus-window-or-workspace-down)
          (key "R" "Mod+Shift" move-window-down-or-to-workspace-down)
          (key "Return" "Mod" maximize-column)
          (key "Return" "Mod+Shift" fullscreen-window)
          (key "Right" "Mod" (spawn [playerctl "next"]))
          (key "S" "Mod" focus-column-or-monitor-right)
          (key "S" "Mod+Shift" move-column-right-or-to-monitor-right)
          (key "Slash" "Mod+Shift" show-hotkey-overlay)
          (key "T" "Mod" (spawn kitty))
          (key "Up" "Mod" (spawn [swayosd-client "--brightness" "raise"]))
          (key "W" "Mod" focus-window-or-workspace-up)
          (key "W" "Mod+Shift" move-window-up-or-to-workspace-up)
          (key "X" "Mod" switch-preset-column-width)
          (key "Z" "Mod" switch-preset-window-height)

          # BUG: Release binds execute with all binds involving that modifier
          # https://github.com/YaLTeR/niri/issues/605
          #// (key "Super_L" "Mod" spawn menu)
          (key "Space" "Mod" (spawn menu))

          # Media keys
          # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
          (key "XF86AudioMute" null (spawn [swayosd-client "--output-volume" "mute-toggle"])) # F1
          (key "XF86AudioLowerVolume" null (spawn [swayosd-client "--output-volume" "lower"])) # F2
          (key "XF86AudioRaiseVolume" null (spawn [swayosd-client "--output-volume" "raise"])) # F3
          (key "XF86AudioPrev" null (spawn [playerctl "previous"])) # F4
          (key "XF86AudioPlay" null (spawn [playerctl "play-pause"])) # F5
          (key "XF86AudioNext" null (spawn [playerctl "next"])) # F6
          (key "XF86MonBrightnessDown" null (spawn [swayosd-client "--brightness" "lower"])) # F7
          (key "XF86MonBrightnessUp" null (spawn [swayosd-client "--brightness" "raise"])) # F8
          (key "XF86AudioMedia" null (spawn [notify-send "test"])) # F12
        ]);
    };
  };
}
