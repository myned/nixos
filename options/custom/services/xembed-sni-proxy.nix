{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.xembed-sni-proxy;
in {
  options.custom.services.xembed-sni-proxy.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    services.xembed-sni-proxy.enable = true; # Support XEmbed tray icons
  };
}
