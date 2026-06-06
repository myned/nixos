{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.wluma;
in {
  options.custom.services.wluma = {
    enable = mkEnableOption "wluma";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # BUG: Adaptive algorithm incurs noticeable idle battery usage
        # https://github.com/maximbaz/wluma/issues/143
        # https://github.com/maximbaz/wluma
        services.wluma = {
          enable = true;

          # https://github.com/maximbaz/wluma/blob/main/config.toml
          settings = {
            als.iio = {
              path = "/sys/bus/iio/devices";

              thresholds = {
                "0" = "night";
                "20" = "dark";
                "250" = "normal";
                "500" = "bright";
                "80" = "dim";
                "800" = "outdoors";
              };
            };

            output.backlight = [
              {
                name = "eDP-1";
                capturer = "wayland";

                path = with config.custom.settings.hardware.igpu; "/sys/class/backlight/${
                  if driver == "amdgpu"
                  then "amdgpu_bl1"
                  else if driver == "i915"
                  then "intel_backlight"
                  else ""
                }";
              }
            ];
          };
        };
      }
    ];
  };
}
