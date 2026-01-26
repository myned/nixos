{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.fw-fanctrl;
in {
  options.custom.services.fw-fanctrl = {
    enable = mkEnableOption "fw-fanctrl";
  };

  config = mkIf cfg.enable {
    # https://github.com/TamtamHero/fw-fanctrl/tree/packaging/nix
    hardware.fw-fanctrl = {
      enable = true;

      # https://github.com/TamtamHero/fw-fanctrl/blob/packaging/nix/doc/configuration.md
      #?? fw-fanctrl reload
      config = {
        defaultStrategy = "custom";

        strategies.custom = {
          fanSpeedUpdateFrequency = 5; # Seconds
          movingAverageInterval = 30; # Seconds

          speedCurve = let
            curve = temp: speed: {inherit temp speed;};
          in [
            (curve 0 0) # Always active
            (curve 30 20)
            (curve 40 30)
            (curve 50 40)
            (curve 60 50)
            (curve 70 60)
            #!! Max fan speed of 60%
            #// (curve 80 70)
            #// (curve 90 80)
            #// (curve 100 100)
          ];
        };
      };
    };
  };
}
