{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.systemd-lock-handler;

  gtklock = getExe pkgs.gtklock;
  hyprlock = getExe config.programs.hyprlock.package;
  niri = getExe config.programs.niri.package;
  pgrep = getExe' pkgs.procps "pgrep";
  sleep = getExe' pkgs.coreutils "sleep";
in {
  options.custom.services.systemd-lock-handler = {
    enable = mkOption {default = false;};
    delay = mkOption {default = 1;}; # Seconds

    lock = mkOption {
      default =
        if config.custom.lockscreen == "gtklock"
        then gtklock
        else if config.custom.lockscreen == "hyprlock"
        then hyprlock
        else "";
    };

    transition = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://sr.ht/~whynothugo/systemd-lock-handler/
    services.systemd-lock-handler.enable = true;

    # https://sr.ht/~whynothugo/systemd-lock-handler/#usage
    # https://github.com/hyprwm/hypridle/issues/49
    systemd.user.services = {
      handle-lock = let
        delay-ms = toString (cfg.delay * 1000); # Milliseconds
      in {
        unitConfig = {
          Description = "Lockscreen";

          # Use Before, not After lock.target
          # https://todo.sr.ht/~whynothugo/systemd-lock-handler/4
          Before = ["lock.target"];
        };

        serviceConfig = {
          Type = "exec";

          ExecCondition = pkgs.writeShellScript "lock-condition" ''
            if ${pgrep} ${config.custom.lockscreen}; then
              exit 1 # Lockscreen process already running
            else
              exit 0 # Lockscreen process not found
            fi
          '';

          # HACK: Default red background immediately shows while lockscreen starts, so use transition
          # https://github.com/YaLTeR/niri/issues/808
          ExecStartPre = mkIf cfg.transition (
            if config.custom.desktop == "niri"
            then "${niri} msg action do-screen-transition --delay-ms ${delay-ms}"
            else ""
          );

          ExecStart = cfg.lock;
        };

        requiredBy = ["lock.target" "sleep.target"];
      };

      handle-sleep = let
        # Transition time is about 1 second
        delay = toString (cfg.delay + 1); # Seconds
      in {
        unitConfig = {
          Description = "Delay sleep for ${delay}s";
          Before = ["sleep.target"];
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${sleep} ${delay}s";
        };

        requiredBy = ["sleep.target"];
      };
    };
  };
}
