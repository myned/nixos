{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.binds;
  hm = config.home-manager.users.${config.custom.username};

  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
  bash = "${pkgs.bash}/bin/bash";
  capacities = "capacities.appimage";
  cat = "${pkgs.coreutils}/bin/cat";
  code = getExe hm.programs.vscode.package;
  ghostty = "${hm.programs.ghostty.package}/bin/ghostty";
  gnome-text-editor = "${pkgs.gnome-text-editor}/bin/gnome-text-editor";
  gradia = getExe pkgs.gradia;
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  inhibit = config.home-manager.users.${config.custom.username}.home.file.".local/bin/inhibit".source;
  jq = "${pkgs.jq}/bin/jq";
  kill = "${pkgs.coreutils}/bin/kill";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  networkmanager_dmenu = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  niri = "${config.programs.niri.package}/bin/niri";
  obsidian = "${pkgs.obsidian}/bin/obsidian";
  pkill = "${pkgs.procps}/bin/pkill";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  power = config.home-manager.users.${config.custom.username}.home.file.".local/bin/power".source;
  proton-pass = getExe pkgs.${config.custom.programs.proton.branch}.proton-pass;
  remote = config.home-manager.users.${config.custom.username}.home.file.".local/bin/remote".source;
  steam = "${config.programs.steam.package}/bin/steam";
  steam-gamescope = getExe (findFirst (p: p.name == "steam-gamescope") "" config.environment.systemPackages);
  sushi = "${pkgs.sushi}/bin/sushi";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  todoist-electron = getExe pkgs.todoist-electron;
  virt-manager = "${config.programs.virt-manager.package}/bin/virt-manager";
  waydroid = "${pkgs.waydroid}/bin/waydroid";
  wl-paste = getExe' pkgs.wl-clipboard "wl-paste";
  pear-desktop = "${pkgs.pear-desktop}/bin/pear-desktop";
  zeditor = getExe hm.programs.zed-editor.package;
in {
  options.custom.desktops.niri.binds = {
    enable = mkEnableOption "binds";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        wayland.windowManager.niri.settings = {
          # https://github.com/niri-wm/niri/wiki/Configuration:-Switch-Events
          switch-events = mkIf (config.custom.profile == "laptop") {
            # Toggle only lid display
            lid-close.spawn = [niri "msg" "output" "eDP-1" "off"];
            lid-open.spawn = [niri "msg" "output" "eDP-1" "on"];
          };

          # https://github.com/YaLTeR/niri/wiki/Configuration:-Key-Bindings
          #?? niri msg action
          #?? Mod = Super/Win, Alt when nested; Mod5 = AltGr
          #?? wev
          binds = let
            # Launch VM
            vm = [
              bash
              "-c"
              ''${remote} --vm --client=remmina --username=Myned --password="$(${cat} ${config.age.secrets."${config.custom.hostname}/vm/myndows.pass".path})" myndows''
            ];
          in {
            # TODO: Focus window if already launched
            # https://github.com/YaLTeR/niri/discussions/267
            #?? niri msg action focus-window --id (niri msg -j windows | jq '.[] | select(.app_id == "";}.id')
            "Ctrl+Alt+1".spawn = ["lifx" "state" "--brightness" "0.01"];
            "Ctrl+Alt+2".spawn = ["lifx" "state" "--brightness" "0.25"];
            "Ctrl+Alt+3".spawn = ["lifx" "state" "--brightness" "0.50"];
            "Ctrl+Alt+4".spawn = ["lifx" "state" "--brightness" "0.75"];
            "Ctrl+Alt+5".spawn = ["lifx" "state" "--brightness" "1.00"];
            "Ctrl+Alt+B".spawn = [pkill config.custom.browser.command];
            "Ctrl+Alt+D".spawn = [waydroid "session" "stop"];
            "Ctrl+Alt+Delete".spawn = [loginctl "terminate-user" config.custom.username];
            "Ctrl+Alt+E".spawn = [pkill "gnome-text-editor"];
            "Ctrl+Alt+G".spawn = [pkill "steam"];
            "Ctrl+Alt+I".spawn = [pkill "zed"];
            "Ctrl+Alt+K".spawn = [pkill "capacities"];
            "Ctrl+Alt+M".spawn = [pkill "pear-desktop"];
            "Ctrl+Alt+P".spawn = [pkill "proton-pass"];
            "Ctrl+Alt+Q".spawn = [bash "-c" ''${kill} -9 "$(${niri} msg -j windows | ${jq} '.[] | select(.is_focused == true).pid')"''];
            "Ctrl+Alt+Space".spawn = ["lifx" "toggle"];
            "Ctrl+Alt+T".spawn = [pkill "ghostty"];
            "Ctrl+Shift+Alt+G".spawn = [pkill "gamescope"];
            "Mod+0".spawn = [swayosd-client "--output-volume" "mute-toggle"];
            "Mod+9".spawn = audio;
            "Mod+A".focus-column-or-monitor-left = [];
            "Mod+Alt+1".spawn = ["lifx" "state" "--kelvin" "1500"];
            "Mod+Alt+2".spawn = ["lifx" "state" "--kelvin" "2500"];
            "Mod+Alt+3".spawn = ["lifx" "state" "--kelvin" "3000"];
            "Mod+Alt+4".spawn = ["lifx" "state" "--kelvin" "4000"];
            "Mod+Alt+5".spawn = ["lifx" "state" "--kelvin" "5000"];
            "Mod+Alt+Escape".spawn = ["lifx" "state" "--color" "red"];
            "Mod+Apostrophe".screenshot._props.show-pointer = false;
            "Mod+B".spawn = [config.custom.browser.command "--profile-directory=Default"];
            "Mod+Backslash".spawn = inhibit;
            "Mod+Backspace".center-column = [];
            "Mod+Bracketleft".switch-layout = "prev";
            "Mod+Bracketright".switch-layout = "next";
            "Mod+Ctrl+A".consume-or-expel-window-left = [];
            "Mod+Ctrl+Apostrophe".screenshot-window = [];
            "Mod+Ctrl+Backspace".toggle-column-tabbed-display = [];
            "Mod+Ctrl+R".move-column-to-workspace-down = [];
            "Mod+Ctrl+S".consume-or-expel-window-right = [];
            "Mod+Ctrl+Shift+A".move-workspace-to-monitor-left = [];
            "Mod+Ctrl+Shift+R".move-workspace-down = [];
            "Mod+Ctrl+Shift+S".move-workspace-to-monitor-right = [];
            "Mod+Ctrl+Shift+W".move-workspace-up = [];
            "Mod+Ctrl+Shift+X".set-window-height = "100%";
            "Mod+Ctrl+Shift+Z".set-window-height = "30%";
            "Mod+Ctrl+Tab".toggle-window-floating = [];
            "Mod+Ctrl+U".spawn = vm;
            "Mod+Ctrl+W".move-column-to-workspace-up = [];
            "Mod+Ctrl+X".set-column-width = "100%";
            "Mod+Ctrl+Z".set-column-width = "30%";
            "Mod+D".spawn = [waydroid "show-full-ui"];
            "Mod+Delete".spawn = [playerctl "play-pause"];
            "Mod+Down".spawn = [swayosd-client "--brightness" "lower"];
            "Mod+E".spawn = [gnome-text-editor "--new-window"];
            "Mod+Equal".spawn = [swayosd-client "--output-volume" "raise"];
            "Mod+Escape".toggle-overview = [];
            "Mod+F".spawn = [nautilus "--new-window"];
            "Mod+G".spawn = steam;
            "Mod+Grave".focus-monitor-next = [];
            "Mod+I".spawn = code;
            "Mod+K".spawn = capacities;
            "Mod+L".spawn = [bash "-c" "${loginctl} lock-session && ${niri} msg action power-off-monitors"];
            "Mod+Left".spawn = [playerctl "previous"];
            "Mod+M".spawn = pear-desktop;
            "Mod+Minus".spawn = [swayosd-client "--output-volume" "lower"];
            "Mod+O".spawn = [hyprpicker "--autocopy"];
            "Mod+P".spawn = proton-pass;
            "Mod+Q".close-window = [];
            "Mod+R".focus-window-or-workspace-down = [];
            "Mod+Return".maximize-column = [];
            "Mod+Right".spawn = [playerctl "next"];
            "Mod+S".focus-column-or-monitor-right = [];
            "Mod+Shift+A".move-column-left-or-to-monitor-left = [];
            "Mod+Shift+Apostrophe".spawn-sh = "${wl-paste} | ${gradia}";
            "Mod+Shift+B".spawn = [config.custom.browser.command "--profile-directory=Profile 2" "--window-name=Work"];
            "Mod+Shift+Backslash".spawn = power;
            "Mod+Shift+D".spawn = [waydroid "app" "launch" "com.YoStarEN.Arknights"];
            "Mod+Shift+G".spawn = steam-gamescope;
            "Mod+Shift+Grave".focus-monitor-previous = [];
            "Mod+Shift+L".spawn = [systemctl "sleep"];
            "Mod+Shift+O".spawn = [hyprpicker "--autocopy --format rgb"];
            "Mod+Shift+R".move-window-down-or-to-workspace-down = [];
            "Mod+Shift+Return".fullscreen-window = [];
            "Mod+Shift+S".move-column-right-or-to-monitor-right = [];
            "Mod+Shift+Slash".show-hotkey-overlay = [];
            "Mod+Shift+Tab".switch-focus-between-floating-and-tiling = [];
            "Mod+Shift+V".spawn = config.custom.menus.clipboard.clear;
            "Mod+Shift+W".move-window-up-or-to-workspace-up = [];
            "Mod+Shift+WheelScrollDown".move-window-down-or-to-workspace-down = [];
            "Mod+Shift+WheelScrollLeft".move-column-left-or-to-monitor-left = [];
            "Mod+Shift+WheelScrollRight".move-column-right-or-to-monitor-right = [];
            "Mod+Shift+WheelScrollUp".move-window-up-or-to-workspace-up = [];
            "Mod+Shift+X".set-window-height = "+10%";
            "Mod+Shift+Z".set-window-height = "-10%";
            "Mod+Slash".spawn = [sushi "/tmp/wallpaper.png"];
            "Mod+T".spawn = ghostty;
            "Mod+Tab".focus-window-previous = [];
            "Mod+U".spawn = virt-manager;
            "Mod+Up".spawn = [swayosd-client "--brightness" "raise"];
            "Mod+V".spawn = config.custom.menus.clipboard.show;
            "Mod+W".focus-window-or-workspace-up = [];
            "Mod+WheelScrollDown".focus-window-or-workspace-down = [];
            "Mod+WheelScrollLeft".focus-column-or-monitor-left = [];
            "Mod+WheelScrollRight".focus-column-or-monitor-right = [];
            "Mod+WheelScrollUp".focus-window-or-workspace-up = [];
            "Mod+X".set-column-width = "+10%";
            "Mod+Z".set-column-width = "-10%";

            #// "Mod+B".spawn = [config.custom.browser.command "-P" "default"];
            #// "Mod+Shift+B".spawn = [config.custom.browser.command "-P" "work" "--name" "firefox-work" "--no-remote"];

            # HACK: Spawn chromium work "profile" in separate data directory for app-id to take effect
            # https://issues.chromium.org/issues/40172351
            #// "Mod+Shift+B".spawn = [config.custom.browser.command "--user-data-dir=${config.custom.programs.chromium.dataDir}-Work" "--class=${config.custom.browser.appId}-work"];

            # BUG: Release binds execute with all binds involving that modifier
            # https://github.com/YaLTeR/niri/issues/605
            # TODO: Uncomment when fixed
            #// "Mod+Shift_L" focus-workspace-previous)
            # TODO: Use "Super_L" when fixed
            "Mod+Space".spawn = config.custom.menus.default.show;
            "Mod+Ctrl+Space".spawn = config.custom.menus.calculator.show;
            "Mod+Ctrl+Shift+Space".spawn = networkmanager_dmenu;
            "Mod+Shift+Space".spawn = config.custom.menus.search.show;

            # Media keys
            # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
            "XF86AudioMute".spawn = [swayosd-client "--output-volume" "mute-toggle"]; # F1
            "XF86AudioLowerVolume".spawn = [swayosd-client "--output-volume" "lower"]; # F2
            "XF86AudioRaiseVolume".spawn = [swayosd-client "--output-volume" "raise"]; # F3
            "XF86AudioPrev".spawn = [playerctl "previous"]; # F4
            "XF86AudioPlay".spawn = [playerctl "play-pause"]; # F5
            "XF86AudioNext".spawn = [playerctl "next"]; # F6
            "XF86MonBrightnessDown".spawn = [swayosd-client "--brightness" "lower"]; # F7
            "XF86MonBrightnessUp".spawn = [swayosd-client "--brightness" "raise"]; # F8
            "XF86AudioMedia".spawn = [notify-send "test"]; # F12
          };
        };
      }
    ];
  };
}
