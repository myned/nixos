{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.portainer;
in {
  options.custom.containers.portainer = {
    enable = mkEnableOption "portainer";

    agent = mkOption {
      default = true;
      type = types.bool;
    };

    server = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    #?? arion-portainer pull
    environment.shellAliases.arion-portainer = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.portainer.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.portainer.settings.services =
      # https://www.portainer.io/
      # https://docs.portainer.io/
      # https://github.com/portainer/portainer
      # https://github.com/portainer/portainer-compose/blob/master/docker-stack.yml
      optionalAttrs cfg.server {
        portainer.service = {
          container_name = "portainer";
          depends_on = ["vpn"];
          image = "portainer/portainer-ee:2.31.3"; # https://hub.docker.com/r/portainer/portainer-ee/tags
          network_mode = "service:vpn"; # 9443/tcp
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/portainer/data:/data"];
        };
      }
      # https://docs.portainer.io/admin/environments/add/docker/agent
      // optionalAttrs cfg.agent {
        agent.service = {
          container_name = "portainer-agent";
          depends_on = ["vpn"];
          image = "portainer/agent:2.31.3"; # https://hub.docker.com/r/portainer/agent/tags
          network_mode = "service:vpn"; # 9001/tcp
          restart = "unless-stopped";

          volumes = [
            "${config.custom.containers.directory}:/host:ro"
            "/var/run/docker.sock:/var/run/docker.sock:ro"
            "/var/lib/docker/volumes:/var/lib/docker/volumes:ro"
          ];
        };
      }
      # https://tailscale.com/kb/1282/docker
      // {
        vpn.service = {
          container_name = "portainer-vpn";
          devices = ["/dev/net/tun:/dev/net/tun"];
          env_file = [config.age.secrets."common/tailscale/container.env".path];
          hostname = "${config.custom.hostname}-portainer";
          image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/portainer/vpn:/var/lib/tailscale"];

          capabilities = {
            NET_ADMIN = true;
          };
        };
      };
  };
}
