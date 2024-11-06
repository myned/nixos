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

      # https://github.com/TamtamHero/fw-fanctrl/blob/packaging/nix/config.json
      #?? fw-fanctrl --reload
      config = {
        defaultStrategy = "custom";

        strategies.custom = {
          fanSpeedUpdateFrequency = 5; # Seconds
          movingAverageInterval = 30; # Seconds
          speedCurve = let
            curve = temp: speed: {inherit temp speed;};
          in [
            (curve 0 0) # Always active
            (curve 40 10)
            (curve 50 20)
            (curve 60 30)
            (curve 70 40)
            (curve 80 50)
            #!! Max fan speed of 50%
          ];
        };
      };
    };
  };
}
