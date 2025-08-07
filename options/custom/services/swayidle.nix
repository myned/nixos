{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.swayidle;

  chayang = getExe pkgs.chayang;
  grep = getExe pkgs.gnugrep;
  hyprctl = getExe config.programs.hyprland.package;
  loginctl = getExe' pkgs.systemd "loginctl";
  niri = getExe config.programs.niri.package;
  pgrep = getExe' pkgs.procps "pgrep";
  pw-cli = getExe' pkgs.pipewire "pw-cli";
  swaymsg = getExe' config.programs.sway.package "swaymsg";
  systemctl = getExe' pkgs.systemd "systemctl";
in {
  options.custom.services.swayidle = {
    enable = mkEnableOption "swayidle";

    dpmsCommand = mkOption {
      default = with config.custom;
        if desktop == "hyprland"
        then "${chayang} -d 15 && ${hyprctl} dispatch dpms off"
        # TODO: Use chayang when wp_single_pixel_buffer_manager_v1 supported
        # https://github.com/YaLTeR/niri/issues/619
        else if desktop == "niri"
        then "${niri} msg action power-off-monitors"
        else if desktop == "sway"
        then "${chayang} -d 15 && ${swaymsg} 'output * dpms off'"
        else "";

      description = "Command to turn off display outputs";
      example = "swaymsg 'output * dpms off'";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/swaywm/swayidle
      # https://wiki.archlinux.org/title/Sway#Idle
      services.swayidle = {
        enable = true;

        # https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd
        #?? man swayidle
        timeouts = [
          {
            # Turn off display if currently locked
            command = ''${pgrep} ${config.custom.lockscreen} && ${cfg.dpmsCommand}'';
            timeout = 10 * 60; # Seconds
          }

          {
            # Turn off display
            command = cfg.dpmsCommand;
            timeout = 15 * 60; # Seconds
          }

          {
            # Lock session
            command = "${loginctl} lock-session";
            timeout = 20 * 60; # Seconds
          }

          {
            # Suspend if no audio
            command = "${pw-cli} info all | ${grep} running || ${systemctl} suspend";
            timeout = 60 * 60; # Seconds
          }
        ];
      };
    };
  };
}
