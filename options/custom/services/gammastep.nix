{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.gammastep;
in {
  options.custom.services.gammastep.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://gitlab.com/chinstrap/gammastep
    services.gammastep = {
      enable = true;
      enableVerboseLogging = true;
      provider = "geoclue2"; # geoclue2 service must be enabled

      temperature = {
        day = 5000;
        night = 4000;
      };

      # TODO: Add keybinds
      settings.general = {
        brightness-day = 1;
        brightness-night = 0.4;
      };
    };
  };
}
