{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.swaylock;
in {
  options.custom.programs.swaylock.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # Allow swaylock to unlock the session
    # https://wiki.nixos.org/wiki/Sway#Swaylock_cannot_be_unlocked_with_the_correct_password
    security.pam.services.swaylock = {};

    # https://github.com/swaywm/swaylock
    home-manager.users.${config.custom.username}.programs.swaylock = {
      enable = true;

      # https://github.com/jirutka/swaylock-effects
      package = pkgs.swaylock-effects;

      # https://github.com/swaywm/swaylock/blob/master/swaylock.1.scd
      #?? man swaylock
      settings = {
        daemonize = true;
        disable-caps-lock-text = true;
        line-uses-inside = true;
        indicator-caps-lock = true;
        indicator-idle-visible = true;
        indicator-radius = 150;
        font-size = 48 * config.custom.scale;
        font = config.stylix.fonts.monospace.name;
        image = mkIf config.custom.services.wallpaper.enable "/tmp/altered.png";
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
        text-caps-lock-color = "cb4b16";
        text-clear-color = "002b36";
        text-color = "93a1a1";
        text-ver-color = "002b36";
        text-wrong-color = "002b36";

        ### swaylock-effects
        # https://github.com/jirutka/swaylock-effects?tab=readme-ov-file#new-features
        clock = true;
        #// indicator = true;
        effect-blur = mkIf config.custom.wallpaper "50x2";
        #// fade-in = 1; # Seconds

        # https://strftime.org/
        datestr = "%a %b %d";
        timestr =
          if config.custom.time == "24h"
          then "%H:%M"
          else "%I:%M %p";
      };
    };
  };
}
