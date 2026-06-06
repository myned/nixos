{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.avizo;
in {
  options.custom.services.avizo.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/misterdanb/avizo
        services.avizo = {
          enable = true;

          # https://github.com/misterdanb/avizo/blob/master/config.ini
          settings = {
            default = {
              time = 1;
              height = 150;
              border-radius = 12;
              background = "#93a1a1";
              border-color = "#002b36";
            };
          };
        };
      }
    ];
  };
}
