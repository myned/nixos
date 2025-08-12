{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.swaylock;
in {
  options.custom.programs.swaylock = {
    enable = mkEnableOption "swaylock";

    effects = mkOption {
      default = false;
      description = "Whether to use swaylock-effects";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Allow swaylock to unlock the session
    # https://wiki.nixos.org/wiki/Sway#Swaylock_cannot_be_unlocked_with_the_correct_password
    security.pam.services.swaylock = {};

    home-manager.users.${config.custom.username} = {
      # https://github.com/swaywm/swaylock
      programs.swaylock = {
        enable = true;

        # https://github.com/jirutka/swaylock-effects
        package =
          if cfg.effects
          then pkgs.swaylock-effects
          else pkgs.swaylock;

        # https://github.com/swaywm/swaylock/blob/master/swaylock.1.scd
        #?? man swaylock
        settings =
          {
            #!! Crashes (red screen) when run through a wrapper
            # https://github.com/swaywm/swaylock/issues/323
            daemonize = !config.custom.services.systemd-lock-handler.enable;

            disable-caps-lock-text = true;
            line-uses-inside = true;
            indicator-caps-lock = true;
            indicator-idle-visible = true;
            indicator-radius = 100;
            font = config.stylix.fonts.monospace.name;
            font-size = 24 * config.custom.scale;
            #// image = mkIf config.custom.services.wallpaper.enable "/tmp/altered.png";

            bs-hl-color = "93a1a1";
            color = "073642";
            inside-caps-lock-color = "002b36";
            inside-clear-color = "002b36";
            inside-color = "002b36";
            inside-ver-color = "002b36";
            inside-wrong-color = "002b36";
            key-hl-color = "6c71c4";
            ring-caps-lock-color = "cb4b16";
            ring-clear-color = "fdf6e3";
            ring-color = "002b36";
            ring-ver-color = "268bd2";
            ring-wrong-color = "dc322f";
            separator-color = "002b36";
            text-caps-lock-color = "00000000";
            text-clear-color = "00000000";
            text-color = "00000000";
            text-ver-color = "00000000";
            text-wrong-color = "00000000";
          }
          // optionalAttrs cfg.effects {
            ### swaylock-effects
            # https://github.com/jirutka/swaylock-effects?tab=readme-ov-file#new-features
            clock = true;
            #// indicator = true;
            effect-blur = mkIf config.custom.services.wallpaper.enable "50x2";
            #// fade-in = 1; # Seconds

            # https://strftime.org/
            datestr = "%a %b %d";

            timestr =
              if config.custom.time == "24h"
              then "%H:%M"
              else "%I:%M %p";
          };
      };

      # https://nix-community.github.io/stylix/options/modules/swaylock.html
      stylix.targets.swaylock.enable = false;
    };
  };
}
