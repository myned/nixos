{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.openwebui;
  containerCfg = config.containers.openwebui;
  hostCfg = config;
in {
  options.custom.containers.openwebui = {
    enable = mkEnableOption "openwebui";
  };

  config = mkIf cfg.enable {
    containers.openwebui.config = {
      nixpkgs.config.allowUnfree = true;

      # https://openwebui.com/
      services.open-webui = {
        enable = true;

        # BUG: Dual-stack IPv4/IPv6 not supported in startup script
        # https://github.com/open-webui/open-webui/discussions/2052
        host = "0.0.0.0";

        port = 80; # TCP

        # https://docs.openwebui.com/reference/env-configuration
        # https://github.com/open-webui/open-webui/blob/main/.env.example
        environment = {
          WEBUI_URL = "https://ai.${hostCfg.custom.domain}";

          #!! Telemetry
          ANONYMIZED_TELEMETRY = "false";
          DO_NOT_TRACK = "true";
          SCARF_NO_ANALYTICS = "true";
        };
      };

      # TODO: Remove when dual-stack is supported
      networking.enableIPv6 = false;

      systemd.services.open-webui.serviceConfig = {
        PrivateUsers = mkForce false;
        AmbientCapabilities = mkForce ["CAP_NET_BIND_SERVICE"];
        CapabilityBoundingSet = mkForce ["CAP_NET_BIND_SERVICE"];
      };
    };
  };
}
