{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.swaync;
in
{
  options.custom.services.swaync.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/ErikReider/SwayNotificationCenter
    services.swaync = {
      enable = true;
      style = ./style.css;

      # https://github.com/ErikReider/SwayNotificationCenter/blob/main/src/configSchema.json
      settings = {
        control-center-width = 750 / config.custom.scale;
        control-center-height = config.custom.height / 2;
        fit-to-screen = false;
        hide-on-clear = true;
        notification-2fa-action = false;
        #// notification-inline-replies = true;
        positionX = "center";
        positionY = "top";
        timeout-low = 5;
        timeout = 5; # normal
        timeout-critical = 0;

        widgets = [
          "notifications"
          "backlight"
          "inhibitors"
          "dnd"
          "title"
        ];
      };
    };
  };
}
