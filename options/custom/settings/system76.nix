{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.system76;
in {
  options.custom.settings.system76 = {
    enable = mkEnableOption "system76";

    enableAll = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/pop-os/system76-power
    hardware.system76 = {
      enableAll = cfg.enableAll;
      power-daemon.enable = true;
    };

    services = {
      # https://github.com/pop-os/system76-scheduler
      system76-scheduler = {
        enable = true;
        useStockConfig = true;
      };

      #!! Conflicts with system76-power
      auto-cpufreq.enable = false;
      power-profiles-daemon.enable = false;
    };
  };
}
