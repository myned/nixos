{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.tuned;
in {
  options.custom.services.tuned = {
    enable = mkEnableOption "tuned";
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

        ppdSettings.profiles = mkIf (config.custom.profile == "laptop") {
          balanced = "balanced-battery";
          performance = "balanced";
          power-saver = "powersave";
        };
      };

      #!! Conflicts with TuneD
      auto-cpufreq.enable = false;
      power-profiles-daemon.enable = false;
      tlp.enable = false;
    };

    #?? powerprofilesctl
    environment.systemPackages = optionals config.services.tuned.ppdSupport [pkgs.power-profiles-daemon];
  };
}
