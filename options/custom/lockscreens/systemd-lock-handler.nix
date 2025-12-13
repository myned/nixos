{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.lockscreens.systemd-lock-handler;
  hm = config.home-manager.users.${config.custom.username};

  gtklock = getExe pkgs.gtklock;
  hyprlock = getExe hm.programs.hyprlock.package;
  niri = getExe config.programs.niri.package;
  pgrep = getExe' pkgs.procps "pgrep";
  sleep = getExe' pkgs.coreutils "sleep";
  swaylock = getExe hm.programs.swaylock.package;
in {
  options.custom.lockscreens.systemd-lock-handler = {
    enable = mkEnableOption "systemd-lock-handler";

    lockCommand = mkOption {
      description = "Command of the lockscreen to execute";
      default = with config.custom;
        if lockscreen == "gtklock"
        then gtklock
        else if lockscreen == "hyprlock"
        then hyprlock
        else if lockscreen == "swaylock"
        then swaylock
        else "";
      example = getExe pkgs.swaylock;
      type = types.str;
    };

    lockDelay = mkOption {
      description = "Time in seconds to wait for the lockscreen before locking";
      default =
        if cfg.transition
        then 1
        else 0;
      example = 5;
      type = types.int;
    };

    suspendDelay = mkOption {
      description = "Time in seconds to wait before suspending";
      default = 5;
      example = 5;
      type = types.int;
    };

    transition = mkOption {
      description = "Whether to fade into the lockscreen";
      default = false;
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
      handle-lock = let
        delay = toString (cfg.lockDelay); # Seconds
        delay-ms = toString (cfg.lockDelay * 1000); # Milliseconds
      in {
        requiredBy = ["lock.target" "sleep.target"];

        unitConfig = {
          Description = "Lockscreen";
          # Use Before, not After lock.target
          # https://todo.sr.ht/~whynothugo/systemd-lock-handler/4
          Before = ["lock.target"];
        };

        serviceConfig = {
          Type = "exec";
          ExecStart = cfg.lockCommand;
          ExecCondition = pkgs.writeShellScript "lock-condition" ''
            if ${pgrep} ${config.custom.lockscreen}; then
              exit 1 # Lockscreen process already running
            else
              exit 0 # Lockscreen process not found
            fi
          '';
          ExecStartPre =
            if cfg.transition
            then
              (
                if config.custom.desktop == "niri"
                then "${niri} msg action do-screen-transition --delay-ms=${delay-ms}"
                else ""
              )
            else "${sleep} ${delay}s";
        };
      };

      handle-sleep = let
        delay = toString (cfg.suspendDelay); # Seconds
      in {
        requiredBy = ["sleep.target"];

        unitConfig = {
          Description = "Delay sleep for ${delay}s";
          Before = ["sleep.target"];
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${sleep} ${delay}s";
        };
      };
    };
  };
}
