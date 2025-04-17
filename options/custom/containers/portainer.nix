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
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    #?? arion-portainer pull
    environment.shellAliases.arion-portainer = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.portainer.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.portainer.settings.services = {
      # https://www.portainer.io/
      # https://docs.portainer.io/
      # https://github.com/portainer/portainer
      # https://github.com/portainer/portainer-compose/blob/master/docker-stack.yml
      portainer.service = mkIf cfg.server {
        container_name = "portainer";
        image = "portainer/portainer-ce:2.27.4"; # https://hub.docker.com/r/portainer/portainer-ce/tags
        ports = ["${config.custom.services.tailscale.ip}:9443:9443/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/portainer/data:/data"];
      };

      # https://docs.portainer.io/admin/environments/add/docker/agent
      agent.service = mkIf cfg.agent {
        container_name = "portainer-agent";
        image = "portainer/agent:2.27.4"; # https://hub.docker.com/r/portainer/agent/tags
        #// ports = ["${config.custom.services.tailscale.ip}:9001:9001/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}:/host:ro"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
          "/var/lib/docker/volumes:/var/lib/docker/volumes:ro"
        ];
      };
    };
  };
}
