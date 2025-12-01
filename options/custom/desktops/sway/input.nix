{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.sway.input;
in {
  options.custom.desktops.sway.input.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        #?? man sway-input
        wayland.windowManager.sway = let
          kensington-orbit = "1149:32934:Kensington_ORBIT_WIRELESS_TB_Mouse";
          protoarc = "9741:4097:Nordic_2.4G_Wireless_Receiver_Mouse";
        in {
          config = {
            # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.config.input
            #?? swaymsg -t get_inputs
            input = {
              # Keyboard
              "type:keyboard" = {
                repeat_delay = "250";
                repeat_rate = "30";
              };

              # Mouse
              "type:pointer" = {
                accel_profile = "flat";
              };

              # Touchpad
              "type:touchpad" = {
                accel_profile = "adaptive";
                click_method = "clickfinger"; # Multi-finger clicks
                drag = "enabled";
                drag_lock = "enabled";
                dwt = "enabled"; # Disable while typing
                natural_scroll = "enabled";
                #// pointer_accel = "0";
                tap = "enabled";
              };

              # Individual devices
              ${kensington-orbit} = {
                accel_profile = "adaptive";
                left_handed = "enabled";
                middle_emulation = "enabled";
                natural_scroll = "enabled";
                pointer_accel = "-0.5";
              };

              # ${protoarc} = {
              #   accel_profile = "flat";
              #   pointer_accel = "0";
              # };
            };

            #// seat = { };
          };

          # BUG: Order must be specified for some settings
          # https://github.com/swaywm/sway/issues/7271
          extraConfig = ''
            input ${kensington-orbit} accel_profile adaptive
          '';
        };
      }
    ];
  };
}
