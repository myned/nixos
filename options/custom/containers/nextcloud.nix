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
      "${config.custom.profile}/nextcloud/.env" = secret "${config.custom.profile}/nextcloud/.env";
      "${config.custom.profile}/nextcloud/db.env" = secret "${config.custom.profile}/nextcloud/db.env";
    };

    #?? arion-nextcloud pull
    environment.shellAliases.arion-nextcloud = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.nextcloud.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.nextcloud.settings.services = {
      # https://github.com/nextcloud/docker
      nextcloud.service = {
        container_name = "nextcloud";
        env_file = [config.age.secrets."${config.custom.profile}/nextcloud/.env".path];
        image = "nextcloud:29-apache";
        ports = ["127.0.0.1:8181:80"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/nextcloud/app:/var/www/html"
          "${config.custom.containers.directory}/nextcloud/data:/var/www/html/data"
        ];

        depends_on = [
          "db"
          "cache"
        ];
      };

      cron.service = {
        container_name = "nextcloud-cron";
        entrypoint = "/cron.sh";
        image = "nextcloud:29-apache";
        restart = "unless-stopped";
        volumes =
          config.virtualisation.arion.projects.nextcloud.settings.services.nextcloud.service.volumes; # volumes_from

        depends_on = [
          "db"
          "cache"
        ];
      };

      cache.service = {
        container_name = "nextcloud-cache";
        image = "redis:latest";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/nextcloud/cache:/data"];
      };

      db.service = {
        container_name = "nextcloud-db";
        env_file = [config.age.secrets."${config.custom.profile}/nextcloud/db.env".path];
        image = "postgres:15";
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/nextcloud/db:/var/lib/postgresql/data"
        ];
      };
    };
  };
}
