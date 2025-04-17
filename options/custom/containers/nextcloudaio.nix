{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.nextcloudaio;
in {
  options.custom.containers.nextcloudaio = {
    enable = mkEnableOption "nextcloudaio";
  };

  config = mkIf cfg.enable {
    #?? arion-nextcloudaio pull
    environment.shellAliases.arion-nextcloudaio = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.nextcloudaio.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.nextcloudaio.settings = {
      services = {
        # https://github.com/nextcloud/all-in-one
        # https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md
        # https://github.com/nextcloud/all-in-one/blob/main/compose.yaml
        nextcloud-aio-mastercontainer.service = {
          container_name = "nextcloud-aio-mastercontainer";
          image = "ghcr.io/nextcloud-releases/all-in-one:latest";
          ports = ["${config.custom.services.tailscale.ip}:8088:8080/tcp"];
          restart = "unless-stopped";

          volumes = [
            "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
            "/var/run/docker.sock:/var/run/docker.sock:ro"
          ];

          environment = {
            APACHE_PORT = 11000;
            APACHE_IP_BINDING = "0.0.0.0";
            NEXTCLOUD_DATADIR = "${config.custom.containers.directory}/nextcloudaio/data";
            NEXTCLOUD_MOUNT = "/mnt/local/nextcloud";
            TALK_PORT = 3479; # 3478
          };
        };
      };

      docker-compose.volumes = {
        nextcloud_aio_mastercontainer.name = "nextcloud_aio_mastercontainer";
      };
    };

    systemd.tmpfiles.settings.nextcloud = {
      "/mnt/local/nextcloud" = {
        z = {
          mode = "0700";
          user = "33"; # www-data
          group = "33"; # www-data
        };
      };
    };
  };
}
