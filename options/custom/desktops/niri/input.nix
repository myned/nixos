{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.input;
in {
  options.custom.desktops.niri.input = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/YaLTeR/niri/wiki/Configuration:-Input
      programs.niri.settings.input = {
        keyboard = {
          repeat-delay = 300;
          repeat-rate = 40;
        };

        touchpad = {
          accel-profile = "adaptive";
          accel-speed = 0.3;
          click-method = "clickfinger"; # Multi-finger click
          dwt = true; # Disable while typing
          dwtp = true; # Disable while trackpointing
          scroll-factor = 0.5;
        };

        mouse = {
          # BUG: Applies to trackball device, switch to "flat" when per-device configuration is supported
          # https://github.com/YaLTeR/niri/issues/371
          accel-profile = "adaptive";

          accel-speed = 0.0;
        };

        trackball = {
          accel-profile = "adaptive";
          accel-speed = 0.5;
          middle-emulation = true;
        };

        power-key-handling.enable = false;

        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "70%";
        };

        workspace-auto-back-and-forth = true;
      };
    };
  };
}
