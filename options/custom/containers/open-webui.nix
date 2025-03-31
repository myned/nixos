{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.open-webui;
in {
  options.custom.containers.open-webui = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    #?? arion-open-webui pull
    environment.shellAliases.arion-open-webui = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.open-webui.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.open-webui.settings.services = {
      # https://github.com/open-webui/open-webui
      # https://docs.openwebui.com/getting-started/quick-start/
      open-webui.service = {
        container_name = "open-webui";
        dns = ["100.100.100.100"]; # Tailscale resolver
        image = "ghcr.io/open-webui/open-webui:v0.5.20";
        network_mode = "host";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/open-webui/data:/app/backend/data"];

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
