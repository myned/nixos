{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland.keywords;
  hm = config.home-manager.users.${config.custom.username};

  audio = hm.home.file.".local/bin/audio".source;
  gnome-text-editor = getExe pkgs.gnome-text-editor;
  grep = getExe pkgs.gnugrep;
  left = hm.home.file.".local/bin/left".source;
  loupe = getExe pkgs.loupe;
  modprobe = getExe' pkgs.kmod "modprobe";
  nautilus = getExe pkgs.nautilus;
  sway-audio-idle-inhibit = getExe pkgs.sway-audio-idle-inhibit;
  uwsm = getExe pkgs.uwsm;
  virsh = getExe' config.virtualisation.libvirtd.package "virsh";
  wallpaper = hm.home.file.".local/bin/wallpaper".source;

  command = command: "${uwsm} app -- ${command}";
in {
  options.custom.desktops.hyprland.keywords = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      wayland.windowManager.hyprland.settings = {
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
            ### Trackballs
            (devices ["compx-2.4g-receiver-mouse" "protoarc-em04"] {
              accel_profile = "custom 1 0 1 5 10";
            })

            (devices ["kensington-orbit-wireless-tb-mouse" "orbit-bt5.0-mouse"] {
              left_handed = true;
              middle_button_emulation = true;
              natural_scroll = true;
              sensitivity = -0.7;
            })

            (devices ["logitech-m570"] {
              accel_profile = "custom 1 0 1 3";
              sensitivity = -0.2;
            })

            ### Mice
            (devices ["nordic-2.4g-wireless-receiver-mouse" "protoarc-em11-nl-mouse"] {
              accel_profile = "flat";
              sensitivity = -0.1;
            })

            (devices ["razer-razer-viper-ultimate" "razer-razer-viper-ultimate-dongle" "razer-razer-viper-ultimate-dongle-1"] {
              accel_profile = "flat";
              sensitivity = -0.1;
            })

            ### Touchpads
            (devices ["wireless-controller-touchpad"] {
              enabled = false;
            })
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
            hm.home.sessionVariables
          )
          ++ [
            "EDITOR, ${gnome-text-editor}"
          ];

        # https://wiki.hyprland.org/Configuring/Keywords/#executing
        exec = [
          (command "${left} --init --scroll kensington-orbit-wireless-tb-mouse") # Enforce left-pawed state
        ];

        exec-once =
          [
            (command sway-audio-idle-inhibit) # Inhibit idle while audio is playing
            (command "${audio} --init") # Enforce audio profile state
            (command config.custom.menus.clipboard.clear-silent) # Clear clipboard history

            # HACK: Launch hidden GTK windows to reduce startup time
            "[workspace special:hidden silent] ${command loupe}"
            "[workspace special:hidden silent] ${command nautilus}"
          ]
          ++ optionals config.custom.vms.passthrough.blacklist [
            # HACK: Delay driver initialization to work around reset issues
            (command "${virsh} list | ${grep} ${config.custom.vms.passthrough.guest} || sudo ${modprobe} ${config.custom.settings.vm.passthrough.driver}")
          ];
      };
    };
  };
}
