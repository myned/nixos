{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.blueman-applet;
in {
  options.custom.services.blueman-applet.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/blueman-project/blueman
        services.blueman-applet.enable = true;
      }
    ];
  };
}
