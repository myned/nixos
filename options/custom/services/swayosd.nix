{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.swayosd;
in {
  options.custom.services.swayosd.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/ErikReider/SwayOSD
    services.swayosd.enable = true;

    ### THEME ###
    # https://github.com/ErikReider/SwayOSD/blob/main/data/style/style.scss
    #!! Options not yet available, files written directly
    home.file.".config/swayosd/style.css".text = '''';
  };
}
