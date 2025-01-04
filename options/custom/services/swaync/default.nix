{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.swaync;
in {
  options.custom.services.swaync.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/ErikReider/SwayNotificationCenter
    services.swaync = {
      enable = true;

      # https://github.com/ErikReider/SwayNotificationCenter/blob/main/data/style/style.scss
      style = let
        border = toString config.custom.border;
        gap = toString config.custom.gap;
      in ''
        .control-center {
          border: ${border} solid #073642;
          margin: ${gap}px;
        }

        .notification.low {
          border: ${border} solid #6c71c4;
        }

        .notification.normal {
          border: ${border} solid #d33682;
        }

        .notification.critical {
          border: ${border} solid #dc322f;
        }

        ${readFile ./style.css}
      '';

      # https://github.com/ErikReider/SwayNotificationCenter/blob/main/src/configSchema.json
      settings = {
        control-center-height = builtins.floor (config.custom.height / 2);
        control-center-positionY = "bottom";
        control-center-width = builtins.floor (750 * config.custom.scale);
        fit-to-screen = false;
        hide-on-clear = true;
        notification-2fa-action = false;
        notification-icon-size = 32;
        #// notification-inline-replies = true;
        notification-window-width = builtins.floor (500 * config.custom.scale);
        positionX = "center";
        positionY = "top";
        timeout = 5; # normal
        timeout-critical = 0;
        timeout-low = 5;

        widgets = [
          "notifications"
          "inhibitors"
          "dnd"
          "title"
        ];
      };
    };
  };
}
