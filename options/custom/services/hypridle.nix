{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  grep = "${pkgs.gnugrep}/bin/grep";
  hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";
  hyprlock = "${config.home-manager.users.${config.custom.username}.programs.hyprlock.package}/bin/hyprlock";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  niri = "${config.programs.niri.package}/bin/niri";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pw-cli = "${pkgs.pipewire}/bin/pw-cli";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  cfg = config.custom.services.hypridle;
in {
  options.custom.services.hypridle.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/hyprwm/hypridle
    # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle
    services.hypridle = {
      enable = true;

      settings = let
        # Workaround for red background immediately showing while lockscreen starts
        # https://github.com/YaLTeR/niri/issues/808
        do-screen-transition = "${niri} msg action do-screen-transition --delay-ms 1000 &&";
      in {
        general = let
          lock = "${pgrep} hyprlock || ${
            if config.custom.desktops.desktop == "niri"
            then do-screen-transition
            else ""
          } ${hyprlock}";
        in {
          before_sleep_cmd = "${lock} --immediate";
          lock_cmd = lock;
        };

        listener = [
          {
            timeout = 15 * 60; # Seconds
            on-timeout = "${loginctl} lock-session";
          }

          {
            timeout = 20 * 60; # Seconds
            on-timeout =
              if config.custom.desktops.desktop == "hyprland"
              then "${hyprctl} dispatch dpms off"
              else if config.custom.desktops.desktop == "niri"
              then "${niri} msg action power-off-monitors"
              else "";
          }

          {
            timeout = 60 * 60; # Seconds
            on-timeout = "${pw-cli} info all | ${grep} running || ${systemctl} suspend-then-hibernate"; # Suspend if no audio
          }
        ];
      };
    };

    # BUG: graphical-session-pre.target may not have WAYLAND_DISPLAY set, so service is skipped
    # https://github.com/nix-community/home-manager/issues/5899
    systemd.user.services.hypridle = {
      Unit = {
        After = mkForce ["graphical-session.target"]; # graphical-session-pre.target
      };
    };
  };
}
