{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland.variables;
in {
  options.custom.desktops.hyprland.variables = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland.settings = {
          # https://wiki.hyprland.org/Configuring/Animations/
          #?? animation = NAME, ONOFF, SPEED, CURVE, STYLE
          animation = [
            "global, 1, 4, default"
            "windows, 1, 4, custom, popin 25%"
            "layers, 1, 4, custom, popin 25%"
            "workspaces, 1, 4, custom, slidevert"
            "specialWorkspace, 1, 4, custom, slidefadevert 25%"
          ];

          # https://wiki.hyprland.org/Configuring/Animations/#curves
          # https://easings.net/
          #?? bezier = NAME, X0, Y0, X1, Y1
          bezier = [
            "custom, 0.5, 1.25, 0.5, 1"
          ];

          # https://wiki.hyprland.org/Configuring/Variables/#binds
          binds = {
            allow_workspace_cycles = true;
            disable_keybind_grabbing = true;
            ignore_group_lock = true;
            scroll_event_delay = 0;
          };

          # https://wiki.hyprland.org/Configuring/Variables/#cursor
          cursor = {
            #// hide_on_key_press = true;
            #// hotspot_padding = config.custom.gap;
            #// min_refresh_rate = 60; # !! Hardware dependent
            #// no_break_fs_vrr = true;
            #// no_hardware_cursors = true;
            no_warps = true;
            zoom_rigid = true;
          };

          # https://wiki.hyprland.org/Configuring/Variables/#debug
          debug = {
            disable_scale_checks = true; #!! Unsupported, may result in pixel misalignment
            enable_stdout_logs = true; # systemd-cat
          };

          # https://wiki.hyprland.org/Configuring/Variables/#decoration
          decoration = {
            blur.enabled = false;
            dim_special = 0.25;
            rounding = config.custom.rounding;

            shadow = {
              color = "rgba(00000040)";
              color_inactive = "rgba(0000001a)";
              range = 50;
              render_power = 4; # Distance falloff
            };
          };

          # https://wiki.hyprland.org/Configuring/Dwindle-Layout/
          dwindle = {
            default_split_ratio = 1.25;
            force_split = 2; # Right
            split_bias = 1; # Larger active window
            split_width_multiplier = 1.5;
          };

          # https://wiki.hyprland.org/Configuring/Variables/#general
          general = {
            "col.active_border" = "rgb(d33682)";
            "col.inactive_border" = "rgba(d3368200)";
            "col.nogroup_border_active" = "rgb(dc322f)";
            "col.nogroup_border" = "rgba(dc322f00)";
            #// allow_tearing = true;
            border_size = config.custom.border;
            extend_border_grab_area = 5;
            gaps_in = config.custom.gap / 4;
            gaps_out = config.custom.gap;
            layout = "scroller";
            #// no_border_on_floating = true;
            #// resize_corner = 3; # Bottom-right
            resize_on_border = true;
            snap.enabled = true;
          };

          # https://wiki.hyprland.org/Configuring/Variables/#gestures
          gestures = {
            workspace_swipe = !config.custom.desktops.hyprland.plugins.hyprscroller;
            workspace_swipe_cancel_ratio = 0.2;
            workspace_swipe_distance = 1000;
            #// workspace_swipe_forever = true;
            workspace_swipe_min_speed_to_force = 10;
          };

          # https://wiki.hyprland.org/Configuring/Variables/#group
          group = {
            "col.border_active" = "rgb(6c71c4)";
            "col.border_inactive" = "rgba(6c71c400)";
            "col.border_locked_active" = "rgb(cb4b16)";
            "col.border_locked_inactive" = "rgba(cb4b1600)";
            #// auto_group = false;
            #// insert_after_current = false;

            # https://wiki.hyprland.org/Configuring/Variables/#groupbar
            groupbar = {
              "col.active" = "rgb(6c71c4)";
              "col.inactive" = "rgba(6c71c400)";
              "col.locked_active" = "rgb(cb4b16)";
              "col.locked_inactive" = "rgba(cb4b1600)";

              font_size =
                if config.custom.hidpi
                then 16
                else 10;

              height = 5;
              render_titles = false;
              text_color = "rgb(93a1a1)";
            };
          };

          # https://wiki.hyprland.org/Configuring/Variables/#input
          input = {
            accel_profile = "adaptive";
            float_switch_override_focus = 0; # Disable float to tile hover focus
            #// focus_on_close = 1; # Focus window under mouse
            follow_mouse = 1; # Hover focus

            # BUG: Refocusing causes multiple issues related to mouse cursor
            # https://github.com/hyprwm/Hyprland/issues/8057
            mouse_refocus = false; # Required to focus last window on close

            repeat_delay = 250;
            repeat_rate = 40;
            sensitivity = 0.5;
            scroll_factor = 1.25;
            #// special_fallthrough = true; # Focus windows under special workspace

            touchpad = {
              clickfinger_behavior = true; # Multi-finger clicks
              natural_scroll = true;
              scroll_factor = 0.5;
            };
          };

          # https://wiki.hyprland.org/Configuring/Master-Layout/
          # Optimized for ultrawide use by default
          master = {
            allow_small_split = true;
            mfact = 0.4;
            slave_count_for_center_master = 0;

            orientation =
              if config.custom.ultrawide
              then "center"
              else "top";
          };

          # https://wiki.hyprland.org/Configuring/Variables/#misc
          misc = {
            #// animate_manual_resizes = true;
            #// animate_mouse_windowdragging = true;
            background_color = "rgb(073642)";
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            focus_on_activate = true;
            font_family = config.stylix.fonts.monospace.name;
            force_default_wallpaper = 0;
            #// initial_workspace_tracking = 2; # All children
            key_press_enables_dpms = true;
            middle_click_paste = false;

            # BUG: Still causes hard freezes
            #// vrr = 2; # VRR in fullscreen
          };

          # https://wiki.hyprland.org/Configuring/Variables/#render
          render = {
            #// explicit_sync = 1;
            #// explicit_sync_kms = 1;
          };

          # https://wiki.hyprland.org/Configuring/Variables/#xwayland
          xwayland = {
            force_zero_scaling = true;
          };
        };
      }
    ];
  };
}
