{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.network-manager-applet;
in {
  options.custom.services.network-manager-applet.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://gitlab.gnome.org/GNOME/network-manager-applet
        services.network-manager-applet.enable = true;
      }
    ];
  };
}
