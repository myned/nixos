{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.gammastep;
in {
  options.custom.services.gammastep = {
    enable = mkEnableOption "gammastep";

    autoBrightness = mkOption {
      default = !config.custom.services.wluma.enable;
      description = "Whether to enable automatic brightness control";
      example = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    custom.services.geoclue2.apps = ["gammastep"];

    home-manager.users.${config.custom.username} = {
      # https://gitlab.com/chinstrap/gammastep
      services.gammastep = {
        enable = true;
        enableVerboseLogging = true;
        dawnTime = "06:00-08:00";
        duskTime = "18:00-20:00";
        provider = mkIf config.services.geoclue2.enable "geoclue2";

        temperature = {
          day = 5000;
          night = 4000;
        };

        # TODO: Add keybinds
        settings.general = mkIf cfg.autoBrightness {
          brightness-day = 1;
          brightness-night = 0.6;
        };
      };
    };
  };
}
