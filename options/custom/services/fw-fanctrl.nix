{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.fw-fanctrl;
in {
  options.custom.services.fw-fanctrl.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/TamtamHero/fw-fanctrl/tree/packaging/nix
    programs.fw-fanctrl = {
      enable = true;

      # https://github.com/TamtamHero/fw-fanctrl/blob/packaging/nix/doc/configuration.md
      #?? fw-fanctrl reload
      config = {
        defaultStrategy = "custom";

        strategies.custom = {
          fanSpeedUpdateFrequency = 10; # Seconds
          movingAverageInterval = 30; # Seconds

          speedCurve = let
            curve = temp: speed: {inherit temp speed;};
          in [
            (curve 0 0) # Always active
            (curve 40 20)
            (curve 50 30)
            (curve 60 35)
            (curve 70 40)
            (curve 80 50)
            (curve 90 60)
            (curve 100 70)
            #!! Max fan speed of 70%
          ];
        };
      };
    };
  };
}
