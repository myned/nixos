{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.lockscreens;
in {
  options.custom.lockscreens = {
    enable = mkOption {default = config.custom.full;};
  };

  config = mkIf cfg.enable {
    custom.lockscreens = {
      hypridle.enable = true;
      #// swayidle.enable = true;
      systemd-lock-handler.enable = true;

      gtklock.enable = config.custom.lockscreen == "gtklock";
      hyprlock.enable = config.custom.lockscreen == "hyprlock";
      swaylock.enable = config.custom.lockscreen == "swaylock";
    };
  };
}
