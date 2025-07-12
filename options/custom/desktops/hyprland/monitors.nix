{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.hyprland.monitors;
in {
  options.custom.desktops.hyprland.monitors = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      wayland.windowManager.hyprland.settings = {
        # https://wiki.hyprland.org/Configuring/Monitors
        #?? monitor = NAME, RESOLUTION, POSITION, SCALE
        monitor = mkBefore [
          ", highrr, auto, ${toString config.custom.scale}"

          # HACK: Ensure the fallback output has a sane resolution
          # https://github.com/hyprwm/Hyprland/issues/7276#issuecomment-2323346668
          #// "FALLBACK, ${toString config.custom.width}x${toString config.custom.height}@60, auto, ${toString config.custom.scale}"
        ];
      };
    };
  };
}
