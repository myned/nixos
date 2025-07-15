{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  grep = "${pkgs.gnugrep}/bin/grep";
  powerprofilesctl = "${pkgs.power-profiles-daemon}/bin/powerprofilesctl";

  cfg = config.custom.services.power-profiles-daemon;
in {
  options.custom.services.power-profiles-daemon = {
    enable = mkOption {default = false;};
    auto = mkOption {default = false;};
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

      # Switch to power-saver mode when on battery or balanced when charging
      # https://wiki.archlinux.org/title/Power_management#Using_a_script_and_an_udev_rule
      udev.extraRules = mkIf cfg.auto ''
        # AC
        SUBSYSTEM=="power_supply", ATTR{type}=="Battery", ATTR{status}=="Charging", RUN+="${powerprofilesctl} set balanced"
        # Battery
        SUBSYSTEM=="power_supply", ATTR{type}=="Battery", ATTR{status}=="Discharging", RUN+="${powerprofilesctl} set power-saver"
      '';
    };

    # Set power profile at boot/resume
    powerManagement = let
      set_profile = toString (pkgs.writeShellScript "set_profile" ''
        if ${grep} 1 /sys/class/power_supply/*/online; then
          # AC
          ${powerprofilesctl} set balanced
        else
          # Battery
          ${powerprofilesctl} set power-saver
        fi
      '');
    in
      mkIf cfg.auto {
        powerUpCommands = set_profile;
        resumeCommands = set_profile;
      };
  };
}
