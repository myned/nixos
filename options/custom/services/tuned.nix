{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.tuned;
in {
  options.custom.services.tuned = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    services = {
      # https://tuned-project.org/
      # https://github.com/redhat-performance/tuned
      tuned = {
        enable = true;

        # https://github.com/redhat-performance/tuned/blob/master/tuned-main.conf
        # https://github.com/redhat-performance/tuned/blob/master/doc/TIPS.txt
        settings = {
          # https://github.com/redhat-performance/tuned/blob/master/doc/manual/modules/performance/con_static-and-dynamic-tuning-in-tuned.adoc
          dynamic_tuning = true;
        };
      };

      #!! Conflicts with TuneD
      auto-cpufreq.enable = false;
      power-profiles-daemon.enable = false;
      tlp.enable = false;
    };
  };
}
