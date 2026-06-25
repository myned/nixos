{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.input;
in {
  options.custom.desktops.niri.input = {
    enable = mkEnableOption "input";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Input
        wayland.windowManager.niri.settings.input = {
          disable-power-key-handling = [];
          focus-follows-mouse = [];
          keyboard.repeat-delay = 400;
          keyboard.repeat-rate = 40;
          mouse.accel-profile = "adaptive"; # flat
          mouse.accel-speed = -0.8;
          mouse.scroll-factor = 1.2;
          touchpad.accel-profile = "adaptive";
          touchpad.accel-speed = 0.2;
          touchpad.click-method = "clickfinger"; # Multi-finger click
          touchpad.dwt = []; # Disable while typing
          touchpad.dwtp = []; # Disable while trackpointing
          touchpad.natural-scroll = [];
          touchpad.scroll-factor = 0.5;
          touchpad.tap = [];
          trackball.accel-profile = "adaptive";
          trackball.accel-speed = -0.7;
          #// trackball.left-handed = [];
          trackball.middle-emulation = [];
          #// trackball.natural-scroll = [];
          #// warp-mouse-to-focus = [];
          workspace-auto-back-and-forth = [];
        };
      }
    ];
  };
}
