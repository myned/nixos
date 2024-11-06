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
  firefox-esr = "${config.home-manager.users.${config.custom.username}.programs.firefox.finalPackage}/bin/firefox-esr";
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
          ctrl = "Control";
          shift = "Shift";
          alt = "Mod1";

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
          # Repeat keybindings
          {
            ### Media
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
          # Press keybindings
          // flags "--no-repeat"
          {
            # TODO: Toggle left handed trackball
            ### Scripts
            "${super}+delete" = "exec inhibit";
            "${super}+${shift}+delete" = "exec vrr";
            "${super}+minus" = "exec audio Flat";
            "${super}+equal" = "exec audio Normalizer";
            "${super}+${shift}+${ctrl}+q" = "exec close";

            ### Messages
            "${ctrl}+delete" = "reload";
            "${ctrl}+${alt}+delete" = "exec ${loginctl} terminate-user ''";

            # Windows
            "${super}+q" = "kill";
            "${super}+${shift}+q" = "exec ${kill} -9 $(${swaymsg} -t get_tree | ${jq} '.. | select(.focused?==true).pid')";
            "${super}+grave" = "sticky toggle";
            "${super}+return" = "fullscreen toggle";
            "${super}+tab" = "focus next";
            "${super}+${shift}+tab" = "focus prev";

            # Containers
            "${super}+up" = "move up";
            "${super}+down" = "move down";
            "${super}+left" = "move left";
            "${super}+right" = "move right";
            "${super}+backslash" = "split toggle";
            "${super}+${shift}+backslash" = "split none";
            "${super}+backspace" = "focus mode_toggle";
            "${super}+${shift}+backspace" = "floating toggle";
            "${super}+bracketleft" = "layout toggle tabbed stacking";
            "${super}+bracketright" = "layout toggle split";
            "${super}+escape" = "focus parent";
            "${super}+${shift}+escape" = "focus child";

            # Workspaces
            "${super}+1" = "workspace 1";
            "${super}+${shift}+1" = "move to workspace 1";
            "${super}+2" = "workspace 2";
            "${super}+${shift}+2" = "move to workspace 2";
            "${super}+3" = "workspace 3";
            "${super}+${shift}+3" = "move to workspace 3";
            "${super}+4" = "workspace 4";
            "${super}+${shift}+4" = "move to workspace 4";
            "${super}+5" = "workspace 5";
            "${super}+${shift}+5" = "move to workspace 5";
            "${super}+6" = "workspace 6";
            "${super}+${shift}+6" = "move to workspace 6";
            "${super}+7" = "workspace 7";
            "${super}+${shift}+7" = "move to workspace 7";
            "${super}+8" = "workspace 8";
            "${super}+${shift}+8" = "move to workspace 8";
            "${super}+9" = "workspace 9";
            "${super}+${shift}+9" = "move to workspace 9";
            "${super}+0" = "workspace 10";
            "${super}+${shift}+0" = "move to workspace 0";
            "${super}+g" = "workspace game";
            "${super}+${shift}+g" = "move to workspace game";
            "${super}+${ctrl}+g" = "workspace gamescope";
            "${super}+z" = "exec workspace prev";
            "${super}+${shift}+z" = "move to workspace prev";
            "${super}+x" = "exec workspace next";
            "${super}+${shift}+x" = "move to workspace next";

            # Scratchpads
            "${super}+a" = "[con_mark=android] scratchpad show";
            "${super}+s" = "[con_mark=steam] scratchpad show";
            "${super}+w" = "[con_mark=vm] scratchpad show";
            "${super}+space" = "scratchpad show";
            "${super}+${shift}+space" = "move to scratchpad";
            "${super}+${middle}" = "move window to scratchpad";
            "${super}+${shift}+${middle}" = "move container to scratchpad";
            "${ctrl}+space" = "exec scratchpad dropdown ${foot} --app-id dropdown";

            ### Commands
            # Clipboard
            "${super}+v" = "exec clipboard";
            "${super}+${shift}+v" = "exec ${cliphist} wipe && ${notify-send} cliphist 'Clipboard cleared' --urgency low";

            # Color picker
            "${super}+p" = "exec {hyprpicker} --autocopy";
            "${super}+${shift}+p" = "exec {hyprpicker} --autocopy --format rgb";

            # Screenshot
            print = "exec {grimblast} --freeze copysave area \"$XDG_SCREENSHOTS_DIR/$(date +'%F %H.%M.%S')\"";
            "${super}+print" = "exec {grimblast} --freeze save area - | ${satty} --filename -";
            "${shift}+print" = "exec {grimblast} --freeze copysave output \"$XDG_SCREENSHOTS_DIR/$(date +'%F %H.%M.%S')\"";
            "${super}+${shift}+print" = "exec {grimblast} --freeze save output - | ${satty} --filename -";

            # Smart home
            "${super}+${alt}+escape" = "exec lifx state --color red";
            "${super}+${alt}+1" = "exec lifx state --kelvin 1500";
            "${super}+${alt}+2" = "exec lifx state --kelvin 2500";
            "${super}+${alt}+3" = "exec lifx state --kelvin 3000";
            "${super}+${alt}+4" = "exec lifx state --kelvin 4000";
            "${super}+${alt}+5" = "exec lifx state --kelvin 5000";
            "${ctrl}+${alt}+space" = "exec lifx toggle";
            "${ctrl}+${alt}+1" = "exec lifx state --brightness 0.01";
            "${ctrl}+${alt}+2" = "exec lifx state --brightness 0.25";
            "${ctrl}+${alt}+3" = "exec lifx state --brightness 0.50";
            "${ctrl}+${alt}+4" = "exec lifx state --brightness 0.75";
            "${ctrl}+${alt}+5" = "exec lifx state --brightness 1.00";

            ### Applications
            "${super}+b" = "exec ${firefox-esr}";
            "${super}+c" = "exec ${codium}";
            "${super}+e" = "exec ${gnome-text-editor}";
            "${super}+f" = "exec ${nautilus}";
            "${super}+k" = "exec ${obsidian}";
            # "${super}+t" = "workspace terminal; exec launch terminal ${foot} --app-id terminal";
            "${super}+t" = "workspace terminal; exec ${kitty}";
            "${super}+${shift}+t" = "exec ${foot}";

            # Kill applications
            "${super}+${shift}+a" = "exec ${waydroid} session stop";
            "${super}+${shift}+s" = "exec ${pkill} steam";
            "${super}+${ctrl}+${shift}+g" = "exec ${pkill} gamescope";

            # Remote desktop
            # https://forum.level1techs.com/t/how-to-seamlessly-run-windows-10-apps-in-a-vm-in-linux/170417
            "${super}+${shift}+w" = "exec vm ${wlfreerdp} /cert:ignore /u:Myned /p:password /v:myndows /dynamic-resolution +gfx-progressive -grab-keyboard";
            "${super}+${ctrl}+${shift}+w" = "exec vm ${xfreerdp} /cert:ignore /u:Myned /p:password /app:explorer.exe /v:myndows +gfx-progressive -grab-keyboard";
          }
          # Release keybindings
          // flags "--no-repeat --release"
          {
            # Menus
            super_l = "exec ${pkill} wofi || ${wofi} --show drun";
            "${ctrl}+super_l" = "exec ${pkill} wofi || calc";
            "${shift}+super_l" = "exec ${pkill} wofi || ${wofi} --show run";
            "${alt}+super_l" = "exec ${pkill} wofi || ${rofi-rbw}";
            "${ctrl}+${shift}+super_l" = "exec ${pkill} || ${networkmanager_dmenu}";

            # Workspaces
            "${super}+control_l" = "workspace music";
            "${super}+shift_l" = "workspace back_and_forth";
            "${super}+alt_l" = "workspace wallpaper";

            # Scratchpad
            "${super}+${shift}+control_l" = "exec hide Picture-in-Picture special:pip";
          }
          # Lockscreen keybindings
          // flags "--no-repeat --release --locked"
          {
            "${super}+l" = "exec ${loginctl} lock-session";
          };
      };

      #// modes = { };

      # Keybindings that are not supported by options
      extraConfig = ''
        # Gesture keybindings
        bindgesture swipe:left workspace prev
        bindgesture swipe:right workspace next

        # Switch keybindings
        bindswitch lid:on exec ${loginctl} lock-session
        #// bindswitch lid:on output '*' power off
        #// bindswitch lid:off output '*' power on
      '';
    };
  };
}
