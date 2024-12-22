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

      settings = {
        general = {
          before_sleep_cmd = "${pgrep} hyprlock || ${hyprlock} --immediate";
          lock_cmd = "${pgrep} hyprlock || ${hyprlock}";
        };

        listener = [
          {
            timeout = 15 * 60; # Seconds
            on-timeout = "${loginctl} lock-session";
          }

          {
            timeout = 20 * 60; # Seconds
            on-timeout = "${hyprctl} dispatch dpms off";
          }

          {
            timeout = 60 * 60; # Seconds
            on-timeout = "${pw-cli} info all | ${grep} running || ${systemctl} suspend-then-hibernate"; # Suspend if no audio
          }
        ];
      };
    };
  };
}
