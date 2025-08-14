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
        settings.general = {
          brightness-day = 1;
          brightness-night = 0.6;
        };
      };
    };
  };
}
