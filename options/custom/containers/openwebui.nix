{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.openwebui;
in {
  options.custom.containers.openwebui = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    #?? arion-openwebui pull
    environment.shellAliases.arion-openwebui = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.openwebui.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.openwebui.settings.services = {
      # https://github.com/open-webui/open-webui
      # https://docs.openwebui.com/getting-started/quick-start/
      openwebui.service = {
        container_name = "openwebui";
        dns = ["100.100.100.100"]; # Tailscale resolver
        image = "ghcr.io/open-webui/open-webui:0.6";
        network_mode = "host";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/openwebui/data:/app/backend/data"];

        environment = {
          PORT = 3033; # 8080/tcp

          #!! Low timeout causes text streaming to halt, increase if reached
          # https://github.com/open-webui/open-webui/issues/11228
          # https://github.com/open-webui/open-webui/issues/11320
          #// AIOHTTP_CLIENT_TIMEOUT = 300; # Seconds
        };
      };
    };
  };
}
