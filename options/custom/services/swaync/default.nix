{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.swaync;
in {
  options.custom.services.swaync.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/ErikReider/SwayNotificationCenter
        services.swaync = {
          enable = true;

          # FIXME: Fix GTK4 theme or use stylix
          # https://github.com/ErikReider/SwayNotificationCenter/blob/main/data/style/style.scss
          #?? GTK_DEBUG=interactive swaync
          style = let
            border = toString config.custom.border;
            gap = toString config.custom.gap;
          in ''
            ${readFile ./style.css}

            .control-center {
              border: ${border}px solid #073642;
              margin: ${gap}px;
            }

            .notification.low {
              border: ${border}px solid #6c71c4;
            }

            .notification.normal {
              border: ${border}px solid #d33682;
            }

            .notification.critical {
              border: ${border}px solid #dc322f;
            }
          '';

          # https://github.com/ErikReider/SwayNotificationCenter/blob/main/src/configSchema.json
          settings = {
            control-center-height = builtins.floor (config.custom.height * 0.5); # 50%
            control-center-positionY = "bottom";
            control-center-width = 750;
            fit-to-screen = true;
            hide-on-clear = true;
            notification-2fa-action = false;
            notification-icon-size = 32;
            #// notification-inline-replies = true;
            notification-window-width = 750;
            positionX = "center";
            positionY = "top";
            timeout = 5; # normal
            timeout-critical = 0;
            timeout-low = 5;

            widgets = [
              "notifications"
              "mpris"
              "volume"
              "backlight"
              "inhibitors"
              "dnd"
              "title"
            ];
          };
        };

        # https://nix-community.github.io/stylix/options/modules/swaync.html
        stylix.targets.swaync.enable = false;
      }
    ];
  };
}
