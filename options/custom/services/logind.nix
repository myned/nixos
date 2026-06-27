{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.logind;
in {
  options.custom.services.logind = {
    enable = mkEnableOption "logind";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Systemd/logind
    # https://wiki.archlinux.org/title/Power_management#ACPI_events
    services.logind.settings = {
      Login = {
        HandleLidSwitch = "sleep";
        HandleLidSwitchDocked = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };
    };

    systemd.sleep.settings.Sleep = {
      AllowSuspendThenHibernate = "no"; # Disable suspend-then-hibernate as it causes unnecessary wakeups
    };
  };
}
