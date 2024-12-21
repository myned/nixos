{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  powerprofilesctl = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl";

  cfg = config.custom.services.power-profiles-daemon;
in {
  options.custom.services.power-profiles-daemon = {
    enable = mkOption {default = false;};
    auto = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://gitlab.freedesktop.org/upower/power-profiles-daemon
    #!! Usage is imperative
    #?? powerprofilesctl set <performance|balanced|power-saver>
    services = {
      power-profiles-daemon.enable = true;

      #!! Conflicts with power-profiles-daemon
      auto-cpufreq.enable = false;
      tlp.enable = false;

      # Switch to power-saver mode when on battery
      # https://wiki.archlinux.org/title/Power_management#Using_a_script_and_an_udev_rule
      udev.extraRules = mkIf cfg.auto ''
        # Battery
        SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${powerprofilesctl} set power-saver"

        # AC
        SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${powerprofilesctl} set balanced"
      '';
    };
  };
}
