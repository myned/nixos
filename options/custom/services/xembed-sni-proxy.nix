{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.xembed-sni-proxy;
in {
  options.custom.services.xembed-sni-proxy.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        services.xembed-sni-proxy.enable = true; # Support XEmbed tray icons
      }
    ];
  };
}
