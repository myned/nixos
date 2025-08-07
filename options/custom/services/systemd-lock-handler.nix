{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.systemd-lock-handler;
  hm = config.home-manager.users.${config.custom.username};

  gtklock = getExe pkgs.gtklock;
  hyprlock = getExe hm.programs.hyprlock.package;
  niri = getExe config.programs.niri.package;
  pgrep = getExe' pkgs.procps "pgrep";
  sleep = getExe' pkgs.coreutils "sleep";
  swaylock = getExe hm.programs.swaylock.package;
in {
  options.custom.services.systemd-lock-handler = {
    enable = mkEnableOption "systemd-lock-handler";

    delay = mkOption {
      default = 1;
      description = "Time in seconds to wait for the lockscreen before suspending";
      example = 5;
      type = types.int;
    };

    lockCommand = mkOption {
      default = with config.custom;
        if lockscreen == "gtklock"
        then gtklock
        else if lockscreen == "hyprlock"
        then hyprlock
        else if lockscreen == "swaylock"
        then swaylock
        else "";

      description = "Command of the lockscreen to execute";
      example = getExe pkgs.swaylock;
      type = types.str;
    };

    transition = mkOption {
      default = false;
      description = "Whether to fade into the lockscreen";
      example = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://sr.ht/~whynothugo/systemd-lock-handler/
    services.systemd-lock-handler.enable = true;

    # https://sr.ht/~whynothugo/systemd-lock-handler/#usage
    # https://github.com/hyprwm/hypridle/issues/49
    systemd.user.services = {
      handle-lock = {
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
          ExecStartPre = let
            delay-ms = toString (cfg.delay * 1000); # Milliseconds
          in
            mkIf cfg.transition (
              if config.custom.desktop == "niri"
              then "${niri} msg action do-screen-transition --delay-ms ${delay-ms}"
              else ""
            );

          ExecStart = cfg.lockCommand;
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
