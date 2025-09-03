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
    services.logind =
      if (versionAtLeast version "25.11")
      then {
        settings = {
          Login = {
            HandleLidSwitch = "suspend";
            HandleLidSwitchDocked = "ignore";
            HandleLidSwitchExternalPower = "ignore";
          };
        };
      }
      else {
        lidSwitch = "suspend";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
      };
  };
}
