{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.cockpit;
in {
  options.custom.services.cockpit = {
    enable = mkEnableOption "cockpit";

    proxy = mkOption {
      default = true;
      description = "Whether Cockpit is behind a reverse proxy";
      example = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://cockpit-project.org/
    # https://github.com/cockpit-project/cockpit
    services.cockpit = {
      enable = true;
      port = 9090;

      allowed-origins =
        [
          "https://${config.custom.hostname}"
        ]
        ++ optionals cfg.proxy [
          "https://cockpit.admin.${config.custom.domain}"
        ];

      # https://cockpit-project.org/guide/latest/cockpit.conf.5.html
      settings = {
        WebService = mkIf cfg.proxy {
          ProtocolHeader = "X-Forwarded-Proto";
          ForwardedForHeader = "X-Forwarded-For";
        };
      };
    };
  };
}
