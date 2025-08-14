{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.greetd;

  cage = getExe pkgs.cage;
  gtkgreet = getExe pkgs.gtkgreet;
  tuigreet = getExe pkgs.tuigreet;
in {
  options.custom.services.greetd = {
    enable = mkEnableOption "greetd";

    greeter = mkOption {
      default = "tuigreet";
      description = "Which greeter to use";
      example = "tuigreet";
      type = types.enum ["gtkgreet" "tuigreet"];
    };
  };

  config = mkIf cfg.enable {
    # https://sr.ht/~kennylevinsen/greetd
    # https://wiki.nixos.org/wiki/Greetd
    # https://wiki.archlinux.org/title/Greetd
    services.greetd = {
      enable = true;

      settings.default_session.command =
        # https://git.sr.ht/~kennylevinsen/gtkgreet
        if cfg.greeter == "gtkgreet"
        then "${cage} -s -- ${gtkgreet}"
        # https://github.com/apognu/tuigreet
        else if cfg.greeter == "tuigreet"
        then let
          # https://strftime.org/
          time =
            if config.custom.time == "24h"
            then "%-H:%M"
            else "%-I:%M %p";
        in
          lib.concatStringsSep " " [
            tuigreet
            "--remember"
            "--remember-user-session"
            "--time"
            "--time-format '%a %b %-m ${time}'"
            "--asterisks"
            "--window-padding 1"
            "--greeting owo"
          ]
        else null;
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
