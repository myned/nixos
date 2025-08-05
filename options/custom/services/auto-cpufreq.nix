{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.auto-cpufreq;
in {
  options.custom.services.auto-cpufreq = {
    enable = mkOption {default = false;};

    max = {
      battery = mkOption {default = null;}; # GHz
      charger = mkOption {default = null;}; # GHz
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/AdnanHodzic/auto-cpufreq
    #?? auto-cpufreq --stats
    #?? cpu-power freqency-info
    #?? grep '' /sys/devices/system/cpu/cpu0/cpufreq/*
    services = {
      auto-cpufreq = {
        enable = true;

        # https://github.com/AdnanHodzic/auto-cpufreq/blob/master/auto-cpufreq.conf-example
        #?? cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
        #?? cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
        #?? cat /sys/firmware/acpi/platform_profile_choices
        settings = {
          battery = {
            energy_performance_preference = "balance_power";
            governor = "powersave";
            platform_profile = "low-power";
            scaling_max_freq = mkIf (isFloat cfg.max.battery || isInt cfg.max.battery) (builtins.floor (cfg.max.battery * 1000 * 1000)); # KHz
            #// turbo = "never"; # Only works with acpi-cpufreq
          };

          charger = {
            energy_performance_preference = "balance_performance";
            governor = "powersave";
            platform_profile = "balanced";
            scaling_max_freq = mkIf (isFloat cfg.max.charger || isInt cfg.max.charger) (builtins.floor (cfg.max.charger * 1000 * 1000)); # KHz
          };
        };
      };

      #!! Conflicts with auto-cpufreq
      power-profiles-daemon.enable = false;
      tlp.enable = false;
      tuned.enable = false;
    };
  };
}
