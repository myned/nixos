{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  systemd-cat = "${pkgs.systemd}/bin/systemd-cat";
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";

  cfg = config.custom.services.greetd;
in {
  options.custom.services.greetd.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://sr.ht/~kennylevinsen/greetd
    # https://github.com/apognu/tuigreet
    services.greetd = {
      enable = true;

      settings.default_session = {
        command = lib.concatStringsSep " " [
          tuigreet
          "--session-wrapper '${systemd-cat} --identifier wm'" # ?? journalctl --identifier wm
          "--remember"
          "--remember-user-session"
          "--time"
          "--time-format '%a %b %-m ${
            if config.custom.time == "24h"
            then "%-H:%M"
            else "%-I:%M %p"
          }'" # https://strftime.org/
          "--asterisks"
          "--window-padding 1"
          "--greeting owo"
        ];
      };
    };

    # Use password at login to unlock keyring
    security.pam.services.greetd.fprintAuth = false;

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
  };
}
