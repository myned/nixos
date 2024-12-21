{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  audio = "~/.local/bin/audio";
  clipse = "${pkgs.clipse}/bin/clipse";
  codium = "${config.home-manager.users.${config.custom.username}.programs.vscode.package}/bin/codium";
  gnome-text-editor = "${pkgs.gnome-text-editor}/bin/gnome-text-editor";
  hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";
  hyprlock = "${config.home-manager.users.${config.custom.username}.programs.hyprlock.package}/bin/hyprlock";
  hyprpicker = "${pkgs.hyprpicker}/bin/hyprpicker";
  inhibit = config.home-manager.users.${config.custom.username}.home.file.".local/bin/inhibit".source;
  jq = "${pkgs.jq}/bin/jq";
  kill = "${pkgs.procps}/bin/kill";
  kitty = "${config.home-manager.users.${config.custom.username}.programs.kitty.package}/bin/kitty";
  left = config.home-manager.users.${config.custom.username}.home.file.".local/bin/left".source;
  loginctl = "${pkgs.systemd}/bin/loginctl";
  menu = config.home-manager.users.${config.custom.username}.home.file.".local/bin/menu".source;
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  networkmanager_dmenu = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  obsidian = "${pkgs.obsidian}/bin/obsidian";
  onlyoffice = "${pkgs.onlyoffice-bin}/bin/onlyoffice-desktopeditors --system-title-bar --xdg-desktop-portal";
  pkill = "${pkgs.procps}/bin/pkill";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rofi-rbw = "${pkgs.rofi-rbw}/bin/rofi-rbw";
  rm = "${pkgs.coreutils}/bin/rm";
  screenshot = "~/.local/bin/screenshot";
  sleep = "${pkgs.coreutils}/bin/sleep";
  smile = "${pkgs.smile}/bin/smile";
  steam = "${config.programs.steam.package}/bin/steam";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  toggle = "~/.local/bin/toggle";
  virt-manager = "${config.programs.virt-manager.package}/bin/virt-manager";
  vm = config.home-manager.users.${config.custom.username}.home.file.".local/bin/vm".source;
  vrr = config.home-manager.users.${config.custom.username}.home.file.".local/bin/vrr".source;
  walker = "${config.home-manager.users.${config.custom.username}.programs.walker.package}/bin/walker";
  waydroid = "${pkgs.waydroid}/bin/waydroid";
  window = config.home-manager.users.${config.custom.username}.home.file.".local/bin/window".source;
  workspace = config.home-manager.users.${config.custom.username}.home.file.".local/bin/workspace".source;
  zoom = config.home-manager.users.${config.custom.username}.home.file.".local/bin/zoom".source;
  blackbox = "${pkgs.blackbox-terminal}/bin/blackbox";
  cliphist = "${pkgs.cliphist}/bin/cliphist";
  foot = "${config.home-manager.users.${config.custom.username}.programs.foot.package}/bin/foot";
  pgrep = "${pkgs.procps}/bin/pgrep";
  satty = "${pkgs.satty}/bin/satty";
  swaylock = "${config.home-manager.users.${config.custom.username} programs.swaylock.package}/bin/swaylock";
  swaymsg = "${config.home-manager.users.${config.custom.username}.wayland.windowManager.sway.package}/bin/swaymsg";
  swaynag = "${config.home-manager.users.${config.custom.username}.wayland.windowManager.sway.package}/bin/swaynag";
  wlfreerdp = "${pkgs.freerdp}/bin/wlfreerdp";
  wofi = "${config.home-manager.users.${config.custom.username}.programs.wofi.package}/bin/wofi";
  xfreerdp = "${pkgs.freerdp}/bin/xfreerdp";

  cfg = config.custom.desktops.sway.binds;
in {
  options.custom.desktops.sway.binds = {
    enable = mkOption {default = false;};
    modifier = mkOption {default = config.home-manager.users.${config.custom.username}.wayland.windowManager.sway.config.modifier;};
  };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.config.keybindings
    # https://i3wm.org/docs/userguide.html#keybindings
    #?? man 5 sway
    #?? wev
    wayland.windowManager.sway = {
      config = {
        keybindings = let
          # Keyboard modifiers
          super = cfg.modifier;
          ctrl = "control";
          shift = "shift";
          alt = "mod1";

          # Mouse bindings
          left = "button1";
          middle = "button2";
          right = "button3";
          scroll_up = "button4";
          scroll_down = "button5";
          scroll_left = "button6";
          scroll_right = "button7";
          back = "button8";
          forward = "button9";

          # Wrap keys in optional bindsym flags
          #?? flags "FLAGS" { "KEY" = "COMMAND"; }
          flags = args: keys:
            lib.concatMapAttrs
            (key: command: {
              "${args} ${key}" = command;
            })
            keys;
        in
          # Repeat binds
          {
            # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
            XF86AudioMute = "exec ${swayosd-client} --output-volume mute-toggle";
            XF86AudioLowerVolume = "exec ${swayosd-client} --output-volume lower";
            XF86AudioRaiseVolume = "exec ${swayosd-client} --output-volume raise";
            XF86AudioPlay = "exec ${playerctl} play-pause";
            XF86AudioPrev = "exec ${playerctl} previous";
            XF86AudioNext = "exec ${playerctl} next";
            XF86MonBrightnessDown = "exec ${swayosd-client} --brightness lower";
            XF86MonBrightnessUp = "exec ${swayosd-client} --brightness raise";

            # TODO: Unused media key
            #// XF86AudioMedia = "exec null";
          }
          # Press binds
          // flags "--no-repeat"
          {
            "${middle}+${super}" = "move window to scratchpad";
            "${middle}+${super}+${shift}" = "move container to scratchpad";
            "1+${ctrl}+${alt}" = "exec lifx state --brightness 0.01";
            "1+${super}" = "workspace 1";
            "1+${super}+${alt}" = "exec lifx state --kelvin 1500";
            "1+${super}+${shift}" = "move to workspace 1";
            "2+${ctrl}+${alt}" = "exec lifx state --brightness 0.25";
            "2+${super}" = "workspace 2";
            "2+${super}+${alt}" = "exec lifx state --kelvin 2500";
            "2+${super}+${shift}" = "move to workspace 2";
            "3+${ctrl}+${alt}" = "exec lifx state --brightness 0.50";
            "3+${super}" = "workspace 3";
            "3+${super}+${alt}" = "exec lifx state --kelvin 3000";
            "3+${super}+${shift}" = "move to workspace 3";
            "4+${ctrl}+${alt}" = "exec lifx state --brightness 0.75";
            "4+${super}" = "workspace 4";
            "4+${super}+${alt}" = "exec lifx state --kelvin 4000";
            "4+${super}+${shift}" = "move to workspace 4";
            "5+${ctrl}+${alt}" = "exec lifx state --brightness 1.00";
            "5+${super}" = "workspace 5";
            "5+${super}+${alt}" = "exec lifx state --kelvin 5000";
            "5+${super}+${shift}" = "move to workspace 5";
            "6+${super}" = "workspace 6";
            "6+${super}+${shift}" = "move to workspace 6";
            "7+${super}" = "workspace 7";
            "7+${super}+${shift}" = "move to workspace 7";
            "8+${super}" = "workspace 8";
            "8+${super}+${shift}" = "move to workspace 8";
            "9+${super}" = "workspace 9";
            "9+${super}+${shift}" = "move to workspace 9";
            "a+${super}" = "[con_mark=android] scratchpad show";
            "a+${super}+${shift}" = "exec ${waydroid} session stop";
            "b+${super}" = "exec ${config.custom.browser.command}";
            "backslash+${super}" = "split toggle";
            "backslash+${super}+${shift}" = "split none";
            "backspace+${super}" = "focus mode_toggle";
            "backspace+${super}+${shift}" = "floating toggle";
            "bracketleft+${super}" = "layout toggle tabbed stacking";
            "bracketright+${super}" = "layout toggle split";
            "c+${super}" = "exec ${codium}";
            "delete+${super}" = "exec inhibit";
            "delete+${super}+${shift}" = "exec vrr";
            "down+${super}" = "move down";
            "e+${super}" = "exec ${gnome-text-editor}";
            "equal+${super}" = "exec audio Normalizer";
            "escape+${super}" = "focus parent";
            "escape+${super}+${alt}" = "exec lifx state --color red";
            "escape+${super}+${shift}" = "focus child";
            "f+${super}" = "exec ${nautilus}";
            "g+${super}" = "workspace game";
            "g+${super}+${ctrl}" = "workspace gamescope";
            "g+${super}+${ctrl}+${shift}" = "exec ${pkill} gamescope";
            "g+${super}+${shift}" = "move to workspace game";
            "grave+${super}" = "sticky toggle";
            "k+${super}" = "exec ${obsidian}";
            "left+${super}" = "move left";
            "minus+${super}" = "exec audio Flat";
            "p+${super}" = "exec ${hyprpicker} --autocopy";
            "p+${super}+${shift}" = "exec ${hyprpicker} --autocopy --format rgb";
            "print+${shift}" = "exec {grimblast} --freeze copysave output \"$XDG_SCREENSHOTS_DIR/$(date +'%F %H.%M.%S')\"";
            "q+${super}" = "kill";
            "q+${super}+${shift}" = "exec ${kill} -9 $(${swaymsg} -t get_tree | ${jq} '.. | select(.focused?==true).pid')";
            "q+${super}+${shift}+${ctrl}" = "exec close";
            "return+${super}" = "fullscreen toggle";
            "right+${super}" = "move right";
            "s+${super}" = "[con_mark=steam] scratchpad show";
            "s+${super}+${shift}" = "exec ${pkill} steam";
            "space+${ctrl}" = "exec scratchpad dropdown ${kitty} --app-id dropdown";
            "space+${ctrl}+${alt}" = "exec lifx toggle";
            "space+${super}" = "scratchpad show";
            "space+${super}+${shift}" = "move to scratchpad";
            "t+${super}" = "workspace terminal; exec ${kitty} --app-id terminal";
            "t+${super}+${shift}" = "exec ${kitty}";
            "tab+${super}" = "focus next";
            "tab+${super}+${shift}" = "focus prev";
            "up+${super}" = "move up";
            "v+${super}" = "exec clipboard";
            "v+${super}+${shift}" = "exec ${cliphist} wipe && ${notify-send} cliphist 'Clipboard cleared' --urgency low";
            "w+${super}" = "[con_mark=vm] scratchpad show";
            "w+${super}+${ctrl}+${shift}" = "exec vm ${xfreerdp} /cert:ignore /u:Myned /p:password /app:explorer.exe /v:myndows +gfx-progressive -grab-keyboard";
            "w+${super}+${shift}" = "exec vm ${wlfreerdp} /cert:ignore /u:Myned /p:password /v:myndows /dynamic-resolution +gfx-progressive -grab-keyboard";
            "x+${super}" = "exec workspace next";
            "x+${super}+${shift}" = "move to workspace next";
            "z+${super}" = "exec workspace prev";
            "z+${super}+${shift}" = "move to workspace prev";
          }
          # Release binds
          // flags "--no-repeat --release"
          {
            "alt_l+${super}" = "workspace wallpaper";
            "control_l+${super}" = "workspace music";
            "control_l+${super}+${shift}" = "exec hide Picture-in-Picture special:pip";
            "shift_l+${super}" = "workspace back_and_forth";
            "super_l" = "exec ${pkill} wofi || ${wofi} --show drun";
            "super_l+${alt}" = "exec ${pkill} wofi || ${rofi-rbw}";
            "super_l+${ctrl}" = "exec ${pkill} wofi || calc";
            "super_l+${ctrl}+${shift}" = "exec ${pkill} || ${networkmanager_dmenu}";
            "super_l+${shift}" = "exec ${pkill} wofi || ${wofi} --show run";
          }
          # Lockscreen binds
          // flags "--no-repeat --release --locked"
          {
            "delete+${ctrl}" = "reload";
            "delete+${ctrl}+${alt}" = "exec ${loginctl} terminate-user ''";
            "l+${super}" = "exec ${loginctl} lock-session";
          };
      };

      #// modes = { };

      # Binds not supported by options
      extraConfig = ''
        # Gesture binds
        bindgesture swipe:left workspace prev
        bindgesture swipe:right workspace next

        # Switch binds
        bindswitch lid:on exec ${loginctl} lock-session
        #// bindswitch lid:on output '*' power off
        #// bindswitch lid:off output '*' power on
      '';
    };
  };
}
