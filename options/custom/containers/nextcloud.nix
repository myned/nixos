{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.nextcloud;
in {
  options.custom.containers.nextcloud.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/nextcloud/.env" = secret "${config.custom.hostname}/nextcloud/.env";
      "${config.custom.hostname}/nextcloud/db.env" = secret "${config.custom.hostname}/nextcloud/db.env";
    };

    #?? arion-nextcloud pull
    environment.shellAliases.arion-nextcloud = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.nextcloud.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.nextcloud.settings.services = {
      # https://github.com/nextcloud/docker
      nextcloud.service = {
        container_name = "nextcloud";
        depends_on = ["db" "cache"];
        env_file = [config.age.secrets."${config.custom.hostname}/nextcloud/.env".path];
        image = "nextcloud:29.0.16-apache"; # https://hub.docker.com/_/nextcloud/tags
        ports = ["8181:80/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/nextcloud/app:/var/www/html"
          "${config.custom.containers.directory}/nextcloud/data:/var/www/html/data"
        ];
      };

      cron.service = {
        container_name = "nextcloud-cron";
        depends_on = ["db" "cache"];
        entrypoint = "/cron.sh";
        image = "nextcloud:29.0.16-apache"; # https://hub.docker.com/_/nextcloud/tags
        restart = "unless-stopped";
        volumes = config.virtualisation.arion.projects.nextcloud.settings.services.nextcloud.service.volumes; # volumes_from
      };

      cache.service = {
        container_name = "nextcloud-cache";
        image = "redis:8.0.3"; # https://hub.docker.com/_/redis/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/nextcloud/cache:/data"];
      };

      db.service = {
        container_name = "nextcloud-db";
        env_file = [config.age.secrets."${config.custom.hostname}/nextcloud/db.env".path];
        image = "postgres:15.13"; # https://hub.docker.com/_/postgres/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/nextcloud/db:/var/lib/postgresql/data"];
      };
    };
  };
}
