{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  chayang = "${pkgs.chayang}/bin/chayang";
  hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  pgrep = "${pkgs.procps}/bin/pgrep";
  swaylock = "${
    config.home-manager.users.${config.custom.username}.programs.swaylock.package
  }/bin/swaylock";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  cfg = config.custom.services.swayidle;
in {
  options.custom.services.swayidle.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/swaywm/swayidle
    # https://wiki.archlinux.org/title/Sway#Idle
    services.swayidle = {
      enable = true;

      events = [
        {
          command = "${pgrep} swaylock || ${swaylock}";
          event = "before-sleep";
        }

        {
          command = "${pgrep} swaylock || ${swaylock}";
          event = "lock";
        }
      ];

      # https://github.com/swaywm/swayidle/blob/master/swayidle.1.scd
      #?? man swayidle
      timeouts = [
        # Lock session
        {
          # FIXME: Grace period likely broken by Hyprland (flicker)
          #// command = "${pgrep} swaylock || ${swaylock} --grace 300"; # 5 minute grace period
          command = "${pgrep} swaylock || ${swaylock}";
          timeout = 15 * 60; # Minutes * 60
        }

        # Fade out display
        {
          # TODO: Use chayang when supported by Hyprland
          # https://github.com/hyprwm/Hyprland/issues/6624
          #// command = "${chayang} -d 15 && ${hyprctl} dispatch dpms off";
          command = "${hyprctl} dispatch dpms off";
          timeout = 20 * 60; # Minutes * 60
          # Resume handled by Hyprland
        }

        # TODO: Possibly migrate to systemd-lock-handler for suspend
        # https://github.com/NixOS/nixpkgs/pull/259196
        # Suspend system
        {
          command = "${systemctl} hybrid-sleep";
          timeout = 60 * 60; # Minutes * 60
        }
      ];
    };
  };
}
