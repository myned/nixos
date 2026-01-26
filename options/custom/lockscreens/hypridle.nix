{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.lockscreens.hypridle;

  grep = getExe pkgs.gnugrep;
  hyprctl = getExe' config.programs.hyprland.package "hyprctl";
  loginctl = getExe' pkgs.systemd "loginctl";
  niri = getExe config.programs.niri.package;
  pgrep = getExe' pkgs.procps "pgrep";
  pw-cli = getExe' pkgs.pipewire "pw-cli";
  systemctl = getExe' pkgs.systemd "systemctl";
in {
  options.custom.lockscreens.hypridle = {
    enable = mkEnableOption "hypridle";

    dpmsCommand = mkOption {
      default =
        if config.custom.desktop == "hyprland"
        then "${hyprctl} dispatch dpms off"
        else if config.custom.desktop == "niri"
        then "${niri} msg action power-off-monitors"
        else "";
    };
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/hyprwm/hypridle
        # https://wiki.hyprland.org/Hypr-Ecosystem/hypridle
        services.hypridle = {
          enable = true;

          settings.listener = [
            {
              # Turn off display if currently locked
              on-timeout = ''${pgrep} ${config.custom.lockscreen} && ${cfg.dpmsCommand}'';
              timeout = 1 * 60; # Minutes
            }

            {
              # Turn off display
              on-timeout = cfg.dpmsCommand;
              timeout = 15 * 60; # Minutes
            }

            {
              # Lock session
              on-timeout = "${loginctl} lock-session";
              timeout = 20 * 60; # Minutes
            }

            {
              # Sleep if no audio
              on-timeout = "${pw-cli} info all | ${grep} running || ${systemctl} sleep";
              timeout = 60 * 60; # Minutes
            }
          ];
        };
      }
    ];
  };
}
