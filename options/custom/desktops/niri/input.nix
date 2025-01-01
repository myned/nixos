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
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Input
        programs.niri.settings.input = {
          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsinputfocus-follows-mouseenable
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "100%";
          };

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsinputpower-key-handlingenable
          power-key-handling.enable = false;

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsinputworkspace-auto-back-and-forth
          workspace-auto-back-and-forth = true;

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsinputkeyboardrepeat-delay
          keyboard = {
            repeat-delay = 300;
            repeat-rate = 40;
          };

          # BUG: Applies to trackball device, switch to "flat" when per-device configuration is supported
          # https://github.com/YaLTeR/niri/issues/371
          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsinputmouseaccel-profile
          mouse = {
            accel-profile = "adaptive";
            accel-speed = -0.2;
          };

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsinputtouchpadaccel-profile
          touchpad = {
            accel-profile = "adaptive";
            accel-speed = 0.3;
            click-method = "clickfinger"; # Multi-finger click
            dwt = true; # Disable while typing
            dwtp = true; # Disable while trackpointing
            scroll-factor = 0.4;
          };

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsinputtrackballaccel-profile
          trackball = {
            accel-profile = "adaptive";
            accel-speed = 0.5;
            middle-emulation = true;
          };
        };
      }
    ];
  };
}
