{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.netbox;
in {
  options.custom.containers.netbox.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/netbox/.env" = secret "${config.custom.profile}/netbox/.env";
      "${config.custom.profile}/netbox/cache.env" = secret "${config.custom.profile}/netbox/cache.env";
      "${config.custom.profile}/netbox/db.env" = secret "${config.custom.profile}/netbox/db.env";
    };

    #?? arion-netbox pull
    environment.shellAliases.arion-netbox = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.netbox.settings.out.dockerComposeYaml}";

    # https://github.com/netbox-community/netbox-docker
    virtualisation.arion.projects.netbox = {
      serviceName = "netbox";

      # https://github.com/netbox-community/netbox-docker/blob/release/docker-compose.yml
      settings.services = let
        netbox = {
          container_name = "netbox";
          depends_on = ["cache" "db"];
          env_file = [config.age.secrets."${config.custom.profile}/netbox/.env".path];
          restart = "unless-stopped";
          volumes = ["${./extra.py}:/etc/netbox/config/extra.py"];

          # https://github.com/netbox-community/netbox-docker/wiki/Using-Netbox-Plugins
          #!! Context modifications require a rebuild
          #?? arion-netbox build
          build.context = "${./.}";
        };
      in {
        netbox.service =
          netbox
          // {
            ports = ["8585:8080"];
          };

        housekeeping.service =
          netbox
          // {
            container_name = "netbox-housekeeping";
            command = ["/opt/netbox/housekeeping.sh"];
            depends_on = ["netbox"];
          };

        worker.service =
          netbox
          // {
            container_name = "netbox-worker";
            command = ["/opt/netbox/venv/bin/python" "/opt/netbox/netbox/manage.py" "rqworker"];
            depends_on = ["netbox"];
          };

        cache.service = {
          container_name = "netbox-cache";
          command = ["sh" "-c" "valkey-server --requirepass $$REDIS_PASSWORD"];
          env_file = [config.age.secrets."${config.custom.profile}/netbox/cache.env".path];
          image = "docker.io/valkey/valkey:8.0";
          restart = "unless-stopped";
        };

        db.service = {
          container_name = "netbox-db";
          env_file = [config.age.secrets."${config.custom.profile}/netbox/db.env".path];
          image = "docker.io/postgres:16";
          restart = "unless-stopped";

          volumes = [
            "${config.custom.containers.directory}/netbox/db:/var/lib/postgresql/data"
          ];
        };
      };
    };
  };
}
