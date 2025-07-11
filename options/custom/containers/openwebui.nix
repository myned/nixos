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
        depends_on = ["vpn"];
        image = "ghcr.io/open-webui/open-webui:latest";
        network_mode = "service:vpn"; # 8080/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/openwebui/data:/app/backend/data"];

        environment = {
          #!! Low timeout causes text streaming to halt, increase if reached
          # https://github.com/open-webui/open-webui/issues/11228
          # https://github.com/open-webui/open-webui/issues/11320
          #// AIOHTTP_CLIENT_TIMEOUT = 300; # Seconds
        };
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "openwebui-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-openwebui";
        image = "ghcr.io/tailscale/tailscale:latest"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/openwebui/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };
  };
}
