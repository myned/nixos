{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  clipse = "${pkgs.clipse}/bin/clipse";
  firefox-esr = "${
    config.home-manager.users.${config.custom.username}.programs.firefox.finalPackage
  }/bin/firefox-esr";
  pkill = "${pkgs.procps}/bin/pkill";
  rm = "${pkgs.coreutils}/bin/rm";
  sleep = "${pkgs.coreutils}/bin/sleep";
  sway-audio-idle-inhibit = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  waybar = "${
    config.home-manager.users.${config.custom.username}.programs.waybar.package
  }/bin/waybar";

  cfg = config.custom.desktops.hyprland.settings;
in {
  options.custom.desktops.hyprland.settings.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      # https://wiki.hyprland.org/Configuring/Variables/#debug
      debug = {
        #// disable_logs = false;
        enable_stdout_logs = true; # systemd-cat

        #!! May result in resolution oddities
        disable_scale_checks = true;
      };

      # https://wiki.hyprland.org/Configuring/Monitors
      #?? monitor = NAME, RESOLUTION, POSITION, SCALE
      monitor = [
        ", highrr, auto, ${toString config.custom.scale}"

        # HACK: Ensure the fallback output has a sane resolution
        # https://github.com/hyprwm/Hyprland/issues/7276#issuecomment-2323346668
        "FALLBACK, ${toString config.custom.width}x${toString config.custom.height}@60, auto, ${toString config.custom.scale}"
      ];

      # https://wiki.hyprland.org/Configuring/Keywords/#setting-the-environment
      #?? envd = VARIABLE, VALUE
      # HACK: Mapped home-manager variables to envd in lieu of upstream fix
      # https://github.com/nix-community/home-manager/issues/2659
      envd = with builtins;
        attrValues (
          mapAttrs (
            name: value: "${name}, ${toString value}"
          )
          config.home-manager.users.${config.custom.username}.home.sessionVariables
        )
        ++ [
          "EDITOR, gnome-text-editor"
        ];

      # https://wiki.hyprland.org/Configuring/Keywords/#executing
      #// exec = [ ];

      # https://wiki.hyprland.org/Configuring/Keywords/#executing
      exec-once =
        [
          "${rm} ~/.config/qalculate/qalc.dmenu.history" # Clear calc history
          "${clipse} -clear" # Clear clipboard history
          "${clipse} -listen" # Monitor clipboard
          sway-audio-idle-inhibit # Inhibit idle while audio is playing

          # TODO: Remove when systemd service fixed
          # https://github.com/Alexays/Waybar/issues/2882
          "${sleep} 2 && ${systemctl} --user restart waybar"

          "[group new lock; tile] ${firefox-esr}"
        ]
        ++ optionals config.custom.wallpaper ["wallpaper"];

      # https://wiki.hyprland.org/Configuring/Variables/#xwayland
      xwayland = {
        force_zero_scaling = true;
      };

      # https://wiki.hyprland.org/Configuring/Master-Layout
      # Optimized for ultrawide use by default
      master = {
        allow_small_split = true;
        always_center_master = true;
        mfact = 0.5;
        orientation = "center";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        "col.active_border" = "rgb(93a1a1)";
        "col.inactive_border" = "rgba(93a1a140)";
        "col.nogroup_border_active" = "rgb(dc322f)";
        "col.nogroup_border" = "rgba(dc322f40)";
        #// allow_tearing = true;
        border_size = config.custom.border;
        gaps_in = config.custom.gap / 2;
        gaps_out = config.custom.gap;
        layout = "master";
        #// no_border_on_floating = true;
        resize_on_border = true;
      };

      # https://wiki.hyprland.org/Configuring/Animations
      #?? animation = NAME, ONOFF, SPEED, CURVE, [STYLE]
      animation = [
        "global, 1, 5, default"
        "specialWorkspace, 1, 5, default, fade"
        "windows, 1, 5, default, slide"
        "layers, 0"
      ];

      # https://wiki.hyprland.org/Configuring/Variables/#decoration
      decoration = {
        "col.shadow_inactive" = "rgba(0000001a)";
        "col.shadow" = "rgba(00000040)";
        blur.enabled = false;
        dim_special = 0;
        rounding = 12;
        shadow_range = 50;
        shadow_render_power = 4; # Distance falloff
      };

      # https://wiki.hyprland.org/Configuring/Variables/#group
      group = {
        "col.border_active" = "rgb(6c71c4)";
        "col.border_inactive" = "rgba(6c71c440)";
        "col.border_locked_active" = "rgb(d33682)";
        "col.border_locked_inactive" = "rgba(d3368240)";
        insert_after_current = false;

        # https://wiki.hyprland.org/Configuring/Variables/#groupbar
        groupbar = {
          "col.active" = "rgb(6c71c4)";
          "col.inactive" = "rgba(6c71c440)";
          "col.locked_active" = "rgb(d33682)";
          "col.locked_inactive" = "rgba(d3368240)";
          font_size =
            if config.custom.hidpi
            then 16
            else 10;
          height = 5;
          render_titles = false;
          text_color = "rgb(93a1a1)";
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        #// animate_manual_resizes = true;
        #// animate_mouse_windowdragging = true;
        background_color = "rgb(073642)";
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
        font_family = "monospace";
        force_default_wallpaper = 0;
        key_press_enables_dpms = true;
        middle_click_paste = false;

        # BUG: Still causes hard freezes
        #// vrr = 2; # VRR in fullscreen
      };

      # https://wiki.hyprland.org/Configuring/Variables/#binds
      binds = {
        allow_workspace_cycles = true;
        disable_keybind_grabbing = true;
        ignore_group_lock = true;
        scroll_event_delay = 0;
      };

      # https://wiki.hyprland.org/Configuring/Variables/#input
      input = {
        accel_profile = "flat";
        float_switch_override_focus = 0; # Disable float to tile hover focus
        focus_on_close = 1; # Focus window under mouse
        follow_mouse = 1; # Hover focus
        #// mouse_refocus = false;
        repeat_delay = 300;
        repeat_rate = 40;
        sensitivity = 0.5;
        #// scroll_factor = 0.75;
        special_fallthrough = true; # Alternative to toggle script

        touchpad = {
          clickfinger_behavior = true; # Multi-finger clicks
          natural_scroll = true;
          scroll_factor = 0.4;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#cursor
      cursor = {
        hide_on_key_press = true;
        hotspot_padding = 10;
        min_refresh_rate = 60; # !! Hardware dependent
        no_break_fs_vrr = true;
        #// no_hardware_cursors = true;
        no_warps = true;
        zoom_rigid = true;
      };

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_cancel_ratio = 0.2;
        workspace_swipe_distance = 1000;
        workspace_swipe_forever = true;
        workspace_swipe_min_speed_to_force = 10;
      };

      # https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs
      #?? device = { name = NAME ... }
      # https://wiki.hyprland.org/Configuring/Variables/#custom-accel-profiles
      # https://wayland.freedesktop.org/libinput/doc/latest/pointer-acceleration.html#the-custom-acceleration-profile
      #?? custom <STEP> <POINTS...>
      # TODO: Combine same devices
      # FIXME: Hotplugging may result in different id
      device = [
        {
          name = "kensington-orbit-wireless-tb-mouse";
          accel_profile = "adaptive";
          sensitivity = -0.6;
          left_handed = true;
          middle_button_emulation = true;
          natural_scroll = true;
        }

        {
          name = "orbit-bt5.0-mouse";
          accel_profile = "adaptive";
          sensitivity = -0.6;
          left_handed = true;
          middle_button_emulation = true;
          natural_scroll = true;
        }

        {
          name = "logitech-m570";
          accel_profile = "custom 1 0 1 3";
          sensitivity = -0.1;
        }

        {
          name = "nordic-2.4g-wireless-receiver-mouse";
          sensitivity = -0.6;
        }

        {
          name = "protoarc-em11-nl-mouse";
          sensitivity = -0.6;
        }

        {
          name = "razer-razer-viper-ultimate-dongle";
          sensitivity = 0;
        }

        {
          name = "wireless-controller-touchpad";
          enabled = false;
        }
      ];
    };
  };
}
