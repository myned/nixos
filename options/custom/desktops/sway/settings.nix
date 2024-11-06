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
  sway-audio-idle-inhibit = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
  waybar = "${config.home-manager.users.${config.custom.username}.programs.waybar.package}/bin/waybar";

  cfg = config.custom.desktops.sway.settings;
in {
  options.custom.desktops.sway.settings.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.config
    # https://github.com/swaywm/sway/blob/master/config.in
    # https://i3wm.org/docs/
    #?? man 5 sway
    wayland.windowManager.sway = {
      config = {
        #!! Module order causes many issues, use extraConfig
        #// assigns = { };

        #?? man sway-bar
        bars = []; # Disable swaybars

        # https://i3wm.org/docs/userguide.html#client_colors
        colors = let
          common = {
            background = "#002b36";
            border = "#073642";
            childBorder = "#073642";
            indicator = "#d33682";
            text = "#93a1a1";
          };
        in {
          background = common.background;

          focused =
            common
            // {
              background = "#6c71c4";
              border = "#6c71c4";
              childBorder = "#6c71c4";
              text = "#002b36";
            };

          focusedInactive =
            common
            // {
              border = "#93a1a1";
              childBorder = "#93a1a1";
            };

          unfocused =
            common
            // {
              border = "#002b36";
              childBorder = "#002b36";
            };

          urgent = common;
        };

        # BUG: floating_modifier does not clear release binds
        # https://github.com/swaywm/sway/issues/4505
        #// floating = { };

        focus = {
          # BUG: Does not switch workspace on activation
          # https://github.com/swaywm/sway/issues/7912
          newWindow = "focus";

          wrapping = "force";
        };

        fonts.size = 11.0;

        # BUG: Other gaps may disable swayfx corners, fixed in master
        # https://github.com/WillPower3309/swayfx/issues/93
        # https://github.com/swaywm/sway/pull/8017
        gaps.inner = 20;

        modes = {}; # Disable modes

        #?? wev
        modifier = "Mod4";

        # https://i3wm.org/docs/userguide.html#_automatically_starting_applications_on_i3_startup
        startup = let
          # Wrap exec in quotes
          #?? <always|once> "COMMAND"
          always = command: {command = "'${command}'";};
          once = command: {command = "'${command}'";};
        in [
          # (always "${pkill} sway-audio-idle-inhibit; ${sway-audio-idle-inhibit}")
          # (always "${pkill} vrr-fs; vrr-fs")

          # # TODO: Use graphical-session.target when merged upstream
          # # https://github.com/NixOS/nixpkgs/pull/218716
          # (always "${pkill} waybar; ${waybar}")

          # (once "${rm} ~/.config/qalculate/qalc.dmenu.history") # Clear calc history
          # (once "${rm} ~/.cache/cliphist/db") # Clear clipboard database
          # (once firefox-esr)
        ];

        window.commands = let
          command = command: {inherit command;};

          # Boilerplate criteria
          #?? criteria = <"ATTR"|{ATTRS = "EXPR"}> <"EXPR"|null>
          criteria = attr: expr: {
            criteria = with builtins;
              if isAttrs attr
              then (mapAttrs (a: e: "^${e}$") attr)
              else {
                ${attr} =
                  if isNull expr
                  then true
                  else "^${expr}$";
              };
          };

          app = expr: criteria "app_id" expr;
          floating = criteria "floating" null;
          mark = expr: criteria "con_mark" expr;
          title = expr: criteria "title" expr;

          attrs = attrs: criteria attrs null;
        in [
          ### Defaults
          # HACK: Prefer default_floating_border when fixed upstream
          # https://github.com/swaywm/sway/issues/7360
          (floating // command "border normal 0")

          ### Workspaces
          # 1
          (attrs {
              app_id = "firefox";
              title = ".*Firefox.*";
            }
            // command "layout tabbed")
          (attrs {
              app_id = "firefox";
              title = "Extension.*";
            }
            // command "floating enable")
          (mark "browser" // command "move to workspace 1")

          # terminal
          (mark "terminal" // command "move to workspace terminal")

          ### Scratchpads
          (mark "dropdown" // command "move to scratchpad")

          ### Sticky
          (mark "pip" // command "border none, floating enable, sticky enable")
        ];
      };

      #!! Applies to every move/workspace invocation
      # The inverse of --no-auto-back-and-forth would be preferable
      #// workspaceAutoBackAndForth = true;

      #// workspaceLayout = "";

      #// workspaceOutputAssign = [ ];

      # Commands not currently configurable via options
      extraConfig = ''
        default_border pixel 2

        # BUG: Does not work
        # https://github.com/swaywm/sway/issues/7360
        default_floating_border normal 0

        # BUG: Unknown/invalid command
        #// primary_selection disabled

        titlebar_border_thickness 2

        workspace 1
      '';
    };
  };
}
