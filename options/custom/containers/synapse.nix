{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.synapse;
in {
  options.custom.containers.synapse = {
    enable = mkEnableOption "synapse";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/synapse/db.env" = secret "${config.custom.profile}/synapse/db.env";

      "${config.custom.profile}/synapse/homeserver.yaml" =
        secret "${config.custom.profile}/synapse/homeserver.yaml"
        // {
          owner = "991"; # synapse
          group = "991"; # synapse
        };
    };

    #?? arion-synapse pull
    environment.shellAliases.arion-synapse = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.synapse.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.synapse.settings.services = {
      # https://element-hq.github.io/synapse/latest/
      # https://github.com/element-hq/synapse
      # https://github.com/element-hq/synapse/tree/develop/contrib/docker
      # https://federationtester.matrix.org/
      #?? arion-synapse exec -- synapse register_new_matrix_user -c /data/homeserver.yaml
      synapse.service = {
        container_name = "synapse";
        depends_on = ["db"];
        image = "ghcr.io/element-hq/synapse:v1.128.0"; # https://github.com/element-hq/synapse/pkgs/container/synapse
        ports = ["8008:8008/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/synapse/data:/data"
          "${config.age.secrets."${config.custom.profile}/synapse/homeserver.yaml".path}:/data/homeserver.yaml"
        ];

        environment = {
          #?? arion-synapse run -- --rm -e SYNAPSE_SERVER_NAME=matrix.example.com -e SYNAPSE_REPORT_STATS=yes synapse generate
          SYNAPSE_CONFIG_PATH = "/data/homeserver.yaml";
        };
      };

      db.service = {
        container_name = "synapse-db";
        env_file = [config.age.secrets."${config.custom.profile}/synapse/db.env".path];
        image = "postgres:15";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/synapse/db:/var/lib/postgresql/data"];
      };
    };

    systemd.tmpfiles.settings.synapse = let
      owner = mode: {
        inherit mode;
        user = "991"; # synapse
        group = "991"; # synapse
      };
    in {
      "${config.custom.containers.directory}/synapse/data" = {
        d = owner "0700";
        z = owner "0700";
      };
    };
  };
}
