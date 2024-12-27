{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.dconf.gnome;
in {
  options.custom.settings.dconf.gnome.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    dconf.settings = with config.home-manager.users.${config.custom.username}.lib.gvariant; {
      "org/gnome/desktop/datetime" = {
        automatic-timezone = mkBoolean true;
      };

      "org/gnome/desktop/interface" = {
        clock-show-date = mkBoolean true;
        clock-show-seconds = mkBoolean false;
        clock-show-weekday = mkBoolean true;
        enable-hot-corners = mkBoolean false;
        gtk-enable-primary-paste = mkBoolean false;
        clock-format = mkString "12h";
      };

      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = mkBoolean false;
      };

      "org/gnome/desktop/peripherals/mouse" = {
        speed = mkDouble 0.3;
        accel-profile = mkString "flat";
      };

      "org/gnome/desktop/peripherals/trackball" = {
        middle-click-emulation = mkBoolean true;
        accel-profile = mkString "adaptive";
      };

      "org/gnome/desktop/privacy" = {
        remember-recent-files = mkBoolean true;
        remove-old-temp-files = mkBoolean true;
        remove-old-trash-files = mkBoolean true;
        old-files-age = mkUint32 7;
        recent-files-max-age = mkInt32 7;
      };

      "org/gnome/desktop/screensaver" = {
        lock-enabled = mkBoolean true;
        lock-delay = mkUint32 (60 * 5); # 5 minutes
      };

      "org/gnome/desktop/session" = {
        idle-delay = mkUint32 (60 * 15); # 15 minutes
      };

      "org/gnome/desktop/sound" = {
        event-sounds = mkBoolean false;
      };

      "org/gnome/desktop/wm/keybindings" = {
        #?? [as]
        activate-window-menu = mkArray type.string [];
        begin-move = mkArray type.string [];
        begin-resize = mkArray type.string [];
        close = mkArray type.string ["<Super>q"];
        cycle-group = mkArray type.string [];
        cycle-group-backward = mkArray type.string [];
        cycle-panels = mkArray type.string [];
        cycle-panels-backward = mkArray type.string [];
        cycle-windows = mkArray type.string [];
        cycle-windows-backward = mkArray type.string [];
        maximize = mkArray type.string [];
        minimize = mkArray type.string [];
        move-to-monitor-down = mkArray type.string [];
        move-to-monitor-left = mkArray type.string [];
        move-to-monitor-right = mkArray type.string [];
        move-to-monitor-up = mkArray type.string [];
        move-to-workspace-1 = mkArray type.string [];
        move-to-workspace-last = mkArray type.string [];
        move-to-workspace-left = mkArray type.string ["<Shift><Super>z"];
        move-to-workspace-right = mkArray type.string ["<Shift><Super>x"];
        panel-run-dialog = mkArray type.string [];
        switch-group = mkArray type.string [];
        switch-group-backward = mkArray type.string [];
        switch-input-source = mkArray type.string [];
        switch-input-source-backward = mkArray type.string [];
        switch-panels = mkArray type.string [];
        switch-panels-backward = mkArray type.string [];
        switch-to-workspace-1 = mkArray type.string [];
        switch-to-workspace-last = mkArray type.string [];
        switch-to-workspace-left = mkArray type.string ["<Super>z"];
        switch-to-workspace-right = mkArray type.string ["<Super>x"];
        toggle-maximized = mkArray type.string [];
        unmaximize = mkArray type.string [];
      };

      "org/gnome/desktop/wm/preferences" = {
        auto-raise = mkBoolean false;
        resize-with-right-button = mkBoolean true;
        num-workspaces = mkInt32 3;
        action-double-click-titlebar = mkString "toggle-maximize";
        action-middle-click-titlebar = mkString "minimize";
        action-right-click-titlebar = mkString "menu";
        button-layout = mkString "appmenu:close";
        focus-mode = mkString "sloppy";
        mouse-button-modifier = mkString "<Super>";
      };

      "org/gnome/gnome-session" = {
        logout-prompt = mkBoolean false;
      };

      "org/gnome/mutter" = {
        attach-modal-dialogs = mkBoolean true;
        center-new-windows = mkBoolean true;
        dynamic-workspaces = mkBoolean false;
        edge-tiling = mkBoolean false;
        workspaces-only-on-primary = mkBoolean true;

        #?? [as]
        experimental-features = mkArray type.string [
          "scale-monitor-framebuffer" # https://wiki.archlinux.org/title/HiDPI#Fractional_scaling
          "variable-refresh-rate" # https://wiki.archlinux.org/title/Variable_refresh_rate#GNOME
        ];
      };

      "org/gnome/mutter/wayland/keybindings" = {
        #?? [as]
        restore-shortcuts = mkArray type.string [];
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = mkBoolean true;
        night-light-schedule-automatic = mkBoolean true;
        night-light-temperature = mkUint32 4000;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        #?? [as]
        help = mkArray type.string [];
        logout = mkArray type.string [];
        magnifier = mkArray type.string [];
        magnifier-zoom-in = mkArray type.string [];
        magnifier-zoom-out = mkArray type.string [];
        screenreader = mkArray type.string [];
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-timeout = mkInt32 (60 * 60); # 1 hour
        power-button-action = mkString "nothing";
        sleep-inactive-ac-type = mkString "suspend";
      };

      "org/gnome/shell" = {
        favorite-apps = mkArray type.string [
          "org.gnome.Nautilus.desktop"
          config.custom.browser.desktop
          "signal-desktop.desktop"
          "org.telegram.desktop.desktop"
          "discord.desktop"
          "youtube-music.desktop"
          "steam.desktop"
          "codium.desktop"
          "obsidian.desktop"
        ];
      };

      "org/gnome/shell/app-switcher" = {
        current-workspace-modules = mkBoolean false;
      };

      "org/gnome/shell/keybindings" = {
        #?? [as]
        focus-active-notification = mkArray type.string [];
        screenshot = mkArray type.string [];
        screenshot-window = mkArray type.string [];
        show-screen-recording-ui = mkArray type.string [];
        toggle-application-view = mkArray type.string [];
        toggle-quick-settings = mkArray type.string [];
        toggle-message-tray = mkArray type.string [];
      };

      "org/gnome/system/location" = {
        enabled = mkBoolean true;
      };

      "org/gnome/tweaks" = {
        show-extensions-notice = mkBoolean false;
      };

      "org/gtk/settings/file-chooser" = {
        clock-format = mkString "12h";
      };

      # Custom keybinds
      #!! custom# must be incremental and updated in custom-keybindings schema
      # TODO: Convert to range function
      # https://discourse.nixos.org/t/nixos-options-to-configure-gnome-keyboard-shortcuts/7275/7
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = mkArray type.string [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom15/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom16/"
        ];
      };

      # Variety
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = mkString "Variety Current";
        command = mkString ''bash -c "loupe $(variety --current)"'';
        binding = mkString "<Super>backslash";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = mkString "Variety Next";
        command = mkString "variety --next";
        binding = mkString "<Super>bracketright";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = mkString "Variety Previous";
        command = mkString "variety --previous";
        binding = mkString "<Super>bracketleft";
      };

      # LIFX
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = mkString "LIFX Toggle";
        command = mkString "lifx toggle";
        binding = mkString "<Control><Alt>space";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
        name = mkString "LIFX Brightness 1%";
        command = mkString "lifx state --brightness 0.01";
        binding = mkString "<Control><Alt>1";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
        name = mkString "LIFX Brightness 25%";
        command = mkString "lifx state --brightness 0.25";
        binding = mkString "<Control><Alt>2";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
        name = mkString "LIFX Brightness 50%";
        command = mkString "lifx state --brightness 0.5";
        binding = mkString "<Control><Alt>3";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
        name = mkString "LIFX Brightness 75%";
        command = mkString "lifx state --brightness 0.75";
        binding = mkString "<Control><Alt>4";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
        name = mkString "LIFX Brightness 100%";
        command = mkString "lifx state --brightness 1";
        binding = mkString "<Control><Alt>5";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
        name = mkString "LIFX Color Red";
        command = mkString "lifx state --color red";
        binding = mkString "<Super><Alt>Escape";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
        name = mkString "LIFX Temperature 1500K";
        command = mkString "lifx state --kelvin 1500";
        binding = mkString "<Super><Alt>1";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" = {
        name = mkString "LIFX Temperature 2500K";
        command = mkString "lifx state --kelvin 2500";
        binding = mkString "<Super><Alt>2";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12" = {
        name = mkString "LIFX Temperature 3000K";
        command = mkString "lifx state --kelvin 3000";
        binding = mkString "<Super><Alt>3";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13" = {
        name = mkString "LIFX Temperature 4000K";
        command = mkString "lifx state --kelvin 4000";
        binding = mkString "<Super><Alt>4";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14" = {
        name = mkString "LIFX Temperature 5000K";
        command = mkString "lifx state --kelvin 5000";
        binding = mkString "<Super><Alt>5";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom15" = {
        name = mkString "Audio Flat";
        command = mkString "audio Flat";
        binding = mkString "<Super>minus";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom16" = {
        name = mkString "Audio Normalizer";
        command = mkString "audio Normalizer";
        binding = mkString "<Super>equal";
      };
    };
  };
}
