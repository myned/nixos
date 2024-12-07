{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  _1password = "${config.programs._1password-gui.package}/bin/1password";
  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
  clipse = "${pkgs.clipse}/bin/clipse";
  firefox-esr = "${config.home-manager.users.${config.custom.username}.programs.firefox.finalPackage}/bin/firefox-esr";
  grep = "${pkgs.gnugrep}/bin/grep";
  left = config.home-manager.users.${config.custom.username}.home.file.".local/bin/left".source;
  loupe = "${pkgs.loupe}/bin/loupe";
  modprobe = "${pkgs.kmod}/bin/modprobe";
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  pkill = "${pkgs.procps}/bin/pkill";
  rm = "${pkgs.coreutils}/bin/rm";
  sleep = "${pkgs.coreutils}/bin/sleep";
  sway-audio-idle-inhibit = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  virsh = "${config.virtualisation.libvirtd.package}/bin/virsh";
  waybar = "${config.home-manager.users.${config.custom.username}.programs.waybar.package}/bin/waybar";

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
      exec = [
        "${left} --init --scroll kensington-orbit-wireless-tb-mouse" # Enforce left-pawed state
      ];

      # https://wiki.hyprland.org/Configuring/Keywords/#executing
      exec-once =
        [
          sway-audio-idle-inhibit # Inhibit idle while audio is playing
          "${audio} --init" # Enforce audio profile state
          "${rm} ~/.cache/walker/clipboard.gob" # Clear clipboard history
          "${_1password} --silent" # Launch password manager in background
          #// "[group new; tile] ${firefox-esr}"

          # HACK: Launch hidden GTK windows to reduce startup time
          "[workspace special:hidden silent] ${loupe}"
          "[workspace special:hidden silent] ${nautilus}"
]
        ++ optionals config.custom.wallpaper [
          "wallpaper"
        ]
        # HACK: Delay driver initialization to work around reset issues
        ++ optionals config.custom.settings.vm.passthrough.init [
          "${virsh} list | ${grep} ${config.custom.settings.vm.passthrough.guest} || sudo ${modprobe} ${config.custom.settings.vm.passthrough.driver}"
        ];

      # https://wiki.hyprland.org/Configuring/Variables/#xwayland
      xwayland = {
        force_zero_scaling = true;
      };

      # https://wiki.hyprland.org/Configuring/Dwindle-Layout/
      dwindle = {
        default_split_ratio = 1.25;
        force_split = 2; # Right
        split_bias = 1; # Larger active window
        split_width_multiplier = 1.5;
      };

      # https://wiki.hyprland.org/Configuring/Master-Layout/
      # Optimized for ultrawide use by default
      master = {
        allow_small_split = true;
        always_center_master = true;
        mfact = 0.5;
        orientation =
          if config.custom.ultrawide
          then "center"
          else "top";
      };

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general = {
        "col.active_border" = "rgb(93a1a1)";
        "col.inactive_border" = "rgba(93a1a140)";
        "col.nogroup_border_active" = "rgb(dc322f)";
        "col.nogroup_border" = "rgba(dc322f40)";
        #// allow_tearing = true;
        border_size = config.custom.border;
        extend_border_grab_area = 5;
        gaps_in = config.custom.gap / 2;
        gaps_out = config.custom.gap;
        layout = "master";
        #// no_border_on_floating = true;
        #// resize_corner = 3; # Bottom-right
        resize_on_border = true;
        snap.enabled = true;
      };

      # https://wiki.hyprland.org/Configuring/Animations
      #?? animation = NAME, ONOFF, SPEED, CURVE, [STYLE]
      animation = [
        "global, 1, 3, default"
        "specialWorkspace, 1, 3, default, fade"
        "windows, 1, 3, default, slide"
        "layers, 0"
      ];

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

      # https://wiki.hyprland.org/Configuring/Variables/#group
      group = {
        "col.border_active" = "rgb(6c71c4)";
        "col.border_inactive" = "rgba(6c71c440)";
        "col.border_locked_active" = "rgb(d33682)";
        "col.border_locked_inactive" = "rgba(d3368240)";
        #// auto_group = false;
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
        font_family = config.custom.font.monospace;
        force_default_wallpaper = 0;
        initial_workspace_tracking = 2; # All children
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
        accel_profile = "adaptive";
        float_switch_override_focus = 0; # Disable float to tile hover focus
        focus_on_close = 1; # Focus window under mouse
        follow_mouse = 1; # Hover focus
        mouse_refocus = false; # Required to focus last window on close
        repeat_delay = 300;
        repeat_rate = 40;
        sensitivity = 0.5;
        #// scroll_factor = 0.75;
        special_fallthrough = true; # Focus windows under special workspace

        touchpad = {
          clickfinger_behavior = true; # Multi-finger clicks
          natural_scroll = true;
          scroll_factor = 0.5;
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#render
      render = {
        #// explicit_sync = 1;
        #// explicit_sync_kms = 1;
      };

      # https://wiki.hyprland.org/Configuring/Variables/#cursor
      cursor = {
        hide_on_key_press = true;
        #// hotspot_padding = config.custom.gap;
        #// min_refresh_rate = 60; # !! Hardware dependent
        #// no_break_fs_vrr = true;
        #// no_hardware_cursors = true;
        no_warps = true;
        zoom_rigid = true;
      };

      # https://wiki.hyprland.org/Configuring/Variables/#gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_cancel_ratio = 0.2;
        workspace_swipe_distance = 1000;
        #// workspace_swipe_forever = true;
        workspace_swipe_min_speed_to_force = 10;
      };

      # https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs
      #?? device = { name = NAME ... }
      # https://wiki.hyprland.org/Configuring/Variables/#custom-accel-profiles
      # https://wayland.freedesktop.org/libinput/doc/latest/pointer-acceleration.html#the-custom-acceleration-profile
      #?? custom <STEP> <POINTS...>
      device = let
        # Combine duplicate devices into one attrset
        #?? (devices ["NAME"] {ATTRS})
        devices = names: attrs: map (name: {inherit name;} // attrs) names;
      in
        flatten [
          (devices ["compx-2.4g-receiver-mouse"] {
            accel_profile = "custom 1 0 1 10 20";
          })

          (devices ["kensington-orbit-wireless-tb-mouse" "orbit-bt5.0-mouse"] {
            accel_profile = "adaptive";
            left_handed = true;
            middle_button_emulation = true;
            natural_scroll = true;
            sensitivity = -0.6;
          })

          (devices ["logitech-m570"] {
            accel_profile = "custom 1 0 1 3";
            sensitivity = -0.2;
          })

          (devices ["nordic-2.4g-wireless-receiver-mouse" "protoarc-em11-nl-mouse"] {
            sensitivity = -0.7;
          })

          (devices ["razer-razer-viper-ultimate" "razer-razer-viper-ultimate-dongle" "razer-razer-viper-ultimate-dongle-1"] {
            sensitivity = -0.7;
          })

          (devices ["wireless-controller-touchpad"] {
            enabled = false;
          })
        ];
    };
  };
}
