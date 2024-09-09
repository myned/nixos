{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  Hyprland = "${config.programs.hyprland.package}/bin/Hyprland";
  systemd-cat = "${pkgs.systemd}/bin/systemd-cat";
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";

  cfg = config.custom.services.greetd;
in
{
  options.custom.services.greetd.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://sr.ht/~kennylevinsen/greetd
    # https://github.com/apognu/tuigreet
    services.greetd = {
      enable = true;

      settings.default_session = {
        command = lib.concatStringsSep " " [
          "${tuigreet}"
          "--session-wrapper '${systemd-cat} --identifier hyprland'" # ?? journalctl --identifier hyprland
          "--cmd ${Hyprland}"
          "--remember"
          "--time"
          "--asterisks"
          "--window-padding 1"
          "--greeting owo"
        ];
      };
    };

    # Attempt to prevent bootlogs from polluting the tty
    # https://github.com/apognu/tuigreet/issues/68
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };

    # FIXME: Does not unlock at login
    security.pam.services.greetd.enableGnomeKeyring = true; # Allow PAM unlocking
  };
}
