{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.affine;
in {
  options.custom.containers.affine = {
    enable = mkEnableOption "affine";
  };

  config = mkIf cfg.enable {
    #?? arion-affine pull
    environment.shellAliases.arion-affine = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.affine.settings.out.dockerComposeYaml}";

    # https://docs.affine.pro/self-host-affine/install/docker-compose-recommend
    # https://docs.affine.pro/self-host-affine/references/docker-compose-yml
    virtualisation.arion.projects.affine.settings.services = {
      # https://affine.pro/
      # https://github.com/toeverything/AFFiNE
      affine.service = {
        container_name = "affine";
        env_file = [config.age.secrets."${config.custom.hostname}/affine/.env".path];
        image = "ghcr.io/toeverything/affine:0.24.1"; # https://github.com/toeverything/AFFiNE/pkgs/container/affine
        ports = ["3010:3010/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/affine/data:/root/.affine"];

        depends_on = {
          cache.condition = "service_healthy";
          db.condition = "service_healthy";
          migration.condition = "service_completed_successfully";
        };
      };

      migration.service = {
        command = ["sh" "-c" "node ./scripts/self-host-predeploy.js"];
        container_name = "affine-migration";
        env_file = [config.age.secrets."${config.custom.hostname}/affine/.env".path];
        image = "ghcr.io/toeverything/affine:0.24.1"; # https://github.com/toeverything/AFFiNE/pkgs/container/affine
        volumes = ["${config.custom.containers.directory}/affine/data:/root/.affine"];

        depends_on = {
          cache.condition = "service_healthy";
          db.condition = "service_healthy";
        };
      };

      cache.service = {
        container_name = "affine-cache";
        image = "redis:8.2.1"; # https://hub.docker.com/_/redis/tags
        restart = "unless-stopped";

        healthcheck = {
          test = ["CMD" "redis-cli" "--raw" "incr" "ping"];
          interval = "10s";
          timeout = "5s";
          retries = 5;
        };
      };

      db.service = {
        container_name = "affine-db";
        env_file = [config.age.secrets."${config.custom.hostname}/affine/db.env".path];
        image = "pgvector/pgvector:0.8.0-pg16"; # https://hub.docker.com/r/pgvector/pgvector/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/affine/db:/var/lib/postgresql/data"];

        healthcheck = {
          test = ["CMD" "pg_isready" "-U" "affine" "-d" "affine"];
          interval = "10s";
          timeout = "5s";
          retries = 5;
        };
      };
    };

    age.secrets = listToAttrs (map (name: {
        inherit name;
        value = {file = "${inputs.self}/secrets/${name}";};
      })
      [
        "${config.custom.hostname}/affine/.env"
        "${config.custom.hostname}/affine/db.env"
      ]);
  };
}
