{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.dconf.gnome-shell;
in {
  options.custom.settings.dconf.gnome-shell.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    dconf.settings = with config.home-manager.users.${config.custom.username}.lib.gvariant; {
      # Extensions
      "org/gnome/shell" = {
        disable-extension-version-validation = mkBoolean false;

        #!! Concatenated with home-manager extensions
        #?? [as]
        enabled-extensions = mkArray type.string ["rounded-window-corners@fxgn"];
      };

      # Auto Move Windows
      "org/gnome/shell/extensions/auto-move-windows" = {
        application-list = mkArray type.string [
          "codium.desktop:1"
          "discord.desktop:1"
          "firefox-esr.desktop:1"
          "obsidian.desktop:1"
          "org.telegram.desktop.desktop:1"
          "signal-desktop.desktop:1"
          "steam.desktop:2"
          "youtube-music.desktop:1"
        ];
      };

      # Caffeine
      "org/gnome/shell/extensions/caffeine" = {
        show-notifications = mkBoolean false;
        duration-timer = mkInt32 4;

        #?? [as]
        toggle-shortcut = mkArray type.string ["<Super>Delete"];
      };

      # Clipboard Indicator
      "org/gnome/shell/extensions/clipboard-indicator" = {
        clear-on-boot = mkBoolean true;
        move-item-first = mkBoolean true;
        strip-text = mkBoolean true;
        display-mode = mkInt32 3;
        preview-size = mkInt32 100;

        #?? [as]
        clear-history = mkArray type.string [];
        next-entry = mkArray type.string [];
        prev-entry = mkArray type.string [];
        private-mode-binding = mkArray type.string [];
        toggle-menu = mkArray type.string ["<Super>v"];
      };

      # Dash to Dock
      "org/gnome/shell/extensions/dash-to-dock" = {
        animate-show-apps = mkBoolean true;
        application-counter-overrides-notifications = mkBoolean true;
        apply-custom-theme = mkBoolean false;
        autohide-in-fullscreen = mkBoolean false;
        custom-theme-shrink = mkBoolean false;
        dance-urgent-applications = mkBoolean true;
        disable-overview-on-startup = mkBoolean true;
        dock-fixed = mkBoolean false;
        hide-tooltip = mkBoolean false;
        hot-keys = mkBoolean false;
        intellihide = mkBoolean true;
        isolate-monitors = mkBoolean true;
        multi-monitor = mkBoolean true;
        require-pressure-to-show = mkBoolean false;
        running-indicator-dominant-color = mkBoolean true;
        scroll-to-focused-application = mkBoolean true;
        show-apps-always-in-the-edge = mkBoolean true;
        show-apps-at-top = mkBoolean true;
        show-dock-urgent-notify = mkBoolean false;
        show-favorites = mkBoolean true;
        show-icons-emblems = mkBoolean true;
        show-icons-notifications-counter = mkBoolean true;
        show-mounts = mkBoolean false;
        show-running = mkBoolean true;
        show-show-apps-button = mkBoolean true;
        show-trash = mkBoolean true;
        show-windows-preview = mkBoolean false;
        workspace-agnostic-urgent-windows = mkBoolean true;
        dash-max-icon-size = mkInt32 36;
        animation-time = mkDouble 0.2;
        hide-delay = mkDouble 0.2;
        show-delay = mkDouble 1.3877787807814457e-17;
        click-action = mkString "focus-minimize-or-appspread";
        dock-position = mkString "BOTTOM";
        intellihide-mode = mkString "ALL_WINDOWS";
        middle-click-action = mkString "quit";
        running-indicator-style = mkString "DOTS";
        scroll-action = mkString "switch-workspace";
        transparency-mode = mkString "DEFAULT";
      };

      # Dash2Dock Lite
      "org/gnome/shell/extensions/dash2dock-lite" = {
        apps-icon-front = mkBoolean true;
        autohide-dash = mkBoolean true;
        icon-shadow = mkBoolean false;
        open-app-animation = mkBoolean true;
        trash-icon = mkBoolean true;
        multi-monitor-preference = mkInt32 1;
        running-indicator-size = mkInt32 2;
        running-indicator-style = mkInt32 1;
        border-radius = mkDouble 8.0;
        animation-bounce = mkDouble 0.1;
        animation-magnify = mkDouble 1.0e-2;
        animation-rise = mkDouble 0.0;
        animation-spread = mkDouble 0.5;
        autohide-speed = mkDouble 0.0;
        dock-padding = mkDouble 1.0;
        edge-distance = mkDouble 0.5;
        icon-size = mkDouble 0.1;
        icon-spacing = mkDouble 0.2;
        pressure-sense-sensitivity = mkDouble 0.0;
        scroll-sensitivity = mkDouble 0.0;

        #?? (dddd)
        background-color = mkTuple [
          (mkDouble 0.0)
          (mkDouble 0.16862741112709045)
          (mkDouble 0.21176470816135406)
          (mkDouble 1.0)
        ];

        notification-badge-color = mkTuple [
          (mkDouble 0.8274509906768799)
          (mkDouble 0.21176470816135406)
          (mkDouble 0.5098039507865906)
          (mkDouble 1.0)
        ];

        running-indicator-color = mkTuple [
          (mkDouble 0.8274509906768799)
          (mkDouble 0.21176470816135406)
          (mkDouble 0.5098039507865906)
          (mkDouble 1.0)
        ];
      };

      # ddterm
      "com/github/amezin/ddterm" = {
        notebook-border = mkBoolean false;
        override-window-animation = mkBoolean false;
        preserve-working-directory = mkBoolean false;
        scrollback-unlimited = mkBoolean true;
        tab-show-shortcuts = mkBoolean false;
        tab-switcher-popup = mkBoolean false;
        transparent-background = mkBoolean false;
        window-resizable = mkBoolean false;
        use-theme-colors = mkBoolean false;
        window-size = mkDouble 0.2;
        background-color = mkString "rgb(0,43,54)";
        foreground-color = mkString "rgb(131,148,150)";
        panel-icon-type = mkString "none";
        tab-policy = mkString "automatic";
        tab-position = mkString "top";
        window-position = mkString "bottom";

        #?? [as]
        ddterm-toggle-hotkey = mkArray type.string ["<Control>space"];
        shortcut-move-tab-next = mkArray type.string [""];
        shortcut-move-tab-prev = mkArray type.string [""];
        shortcut-next-tab = mkArray type.string [""];
        shortcut-prev-tab = mkArray type.string [""];
        shortcut-toggle-maximize = mkArray type.string [""];
        shortcut-win-new-tab = mkArray type.string ["<Shift><Control>t"];
        shortcut-window-size-dec = mkArray type.string [""];
        shortcut-window-size-inc = mkArray type.string [""];

        palette = mkArray type.string [
          "rgb(7,54,66)"
          "rgb(220,50,47)"
          "rgb(133,153,0)"
          "rgb(181,137,0)"
          "rgb(38,139,210)"
          "rgb(211,54,130)"
          "rgb(42,161,152)"
          "rgb(238,232,213)"
          "rgb(0,43,54)"
          "rgb(203,75,22)"
          "rgb(88,110,117)"
          "rgb(101,123,131)"
          "rgb(131,148,150)"
          "rgb(108,113,196)"
          "rgb(147,161,161)"
          "rgb(253,246,227)"
        ];
      };

      # Hide Top Bar
      "org/gnome/shell/extensions/hidetopbar" = {
        animation-time-overview = mkDouble 0.2;
        pressure-threshold = mkDouble 0.0;
        enable-active-window = mkBoolean false;
        mouse-sensitive = mkBoolean true;
        mouse-sensitive-fullscreen-window = mkBoolean false;
      };

      # Just Perfection
      "org/gnome/shell/extensions/just-perfection" = {
        background-menu = mkBoolean false;
        search = mkBoolean false;
        switcher-popup-delay = mkBoolean false;
        window-demands-attention-focus = mkBoolean true;
        world-clock = mkBoolean false;
        startup-status = mkInt32 0;
      };

      # Media Controls
      "org/gnome/shell/extensions/mediacontrols" = {
        colored-player-icon = mkBoolean true;
        hide-media-notification = mkBoolean true;
        scroll-labels = mkBoolean true;
        show-control-icons = mkBoolean false;
        show-label = mkBoolean true;
        show-player-icon = mkBoolean true;
        label-width = mkUint32 0;
        extension-position = mkString "Right";
        mouse-action-left = mkString "PLAY_PAUSE";
        mouse-action-middle = mkString "QUIT_PLAYER";
      };

      # Rounded Window Corners Reborn
      "org/gnome/shell/extensions/rounded-window-corners" = {
        skip-libadwaita-app = mkBoolean true;
        skip-libhandy-app = mkBoolean true;
      };

      # Tiling Assistant
      "org/gnome/shell/extensions/tiling-assistant" = {
        adapt-edge-tiling-to-favorite-layout = mkBoolean true;
        enable-advanced-experimental-features = mkBoolean true;
        enable-raise-tile-group = mkBoolean false;
        enable-tiling-popup = mkBoolean false;
        maximize-with-gap = mkBoolean true;
        active-window-hint = mkInt32 0;
        default-move-mode = mkInt32 1;
        dynamic-keybinding-behavior = mkInt32 4;
        ignore-ta-mod = mkInt32 0;
        move-adaptive-tiling-mod = mkInt32 0;
        move-favorite-layout-mod = mkInt32 1;
        screen-bottom-gap = mkInt32 20;
        screen-left-gap = mkInt32 20;
        screen-right-gap = mkInt32 20;
        screen-top-gap = mkInt32 20;
        window-gap = mkInt32 20;
        active-window-hint-color = mkString "rgb(211,54,130)";

        #?? [as]
        center-window = mkArray type.string [];
        favorite-layouts = mkArray type.string ["0"];
        restore-window = mkArray type.string ["<Super>BackSpace"];
        tile-edit-mode = mkArray type.string [];
        tile-maximize = mkArray type.string ["<Super>Return"];
        tile-maximize-vertically = mkArray type.string [];
        tile-maximize-horizontally = mkArray type.string [];
        tile-bottom-half = mkArray type.string ["<Super>r"];
        tile-bottomleft-quarter = mkArray type.string [];
        tile-bottomright-quarter = mkArray type.string [];
        tile-left-half = mkArray type.string ["<Super>a"];
        tile-right-half = mkArray type.string ["<Super>s"];
        tile-top-half = mkArray type.string ["<Super>w"];
        tile-topleft-quarter = mkArray type.string [];
        tile-topright-quarter = mkArray type.string [];
        toggle-always-on-top = mkArray type.string [];
      };
    };
  };
}
