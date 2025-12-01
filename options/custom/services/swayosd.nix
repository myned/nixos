{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.swayosd;
in {
  options.custom.services.swayosd.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/ErikReider/SwayOSD
        services.swayosd.enable = true;

        ### THEME ###
        # https://github.com/ErikReider/SwayOSD/blob/main/data/style/style.scss
        #!! Options not yet available, files written directly
        xdg.configFile."swayosd/style.css".text = '''';
      }
    ];
  };
}
