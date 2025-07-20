{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.rustdesk;
in {
  options.custom.containers.rustdesk = {
    enable = mkEnableOption "rustdesk";
  };

  config = mkIf cfg.enable {
    #?? arion-rustdesk pull
    environment.shellAliases.arion-rustdesk = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.rustdesk.settings.out.dockerComposeYaml}";

    # https://github.com/rustdesk/rustdesk
    # https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/
    #?? sudo cat /containers/rustdesk/data/id_ed25519.pub
    virtualisation.arion.projects.rustdesk.settings.services = {
      hbbs.service = {
        command = ["hbbs"];
        container_name = "rustdesk-hbbs";
        image = "rustdesk/rustdesk-server:1.1.14"; # https://hub.docker.com/r/rustdesk/rustdesk-server/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/rustdesk/data:/root"];

        ports = [
          "21115:21115/tcp" # NAT test
          "21116:21116/tcp" # Hole-punching/connection
          "21116:21116/udp" # ID/heartbeat
          "21118:21118/tcp" # Web clients
        ];
      };

      hbbr.service = {
        command = ["hbbr"];
        container_name = "rustdesk-hbbr";
        image = "rustdesk/rustdesk-server:1.1.14"; # https://hub.docker.com/r/rustdesk/rustdesk-server/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/rustdesk/data:/root"];

        ports = [
          "21117:21117/tcp" # Relay
          "21119:21119/tcp" # Web clients
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        21115
        21116
        21117
        21118
        21119
      ];

      allowedUDPPorts = [
        21116
      ];
    };
  };
}
