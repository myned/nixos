{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.synapse;
in {
  options.custom.containers.synapse = {
    enable = mkEnableOption "synapse";

    dataDir = mkOption {
      description = "Directory to store data subject to retention";
      default = null;
      example = "/mnt/synapse";
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
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
        depends_on = ["db" "vpn"];
        image = "ghcr.io/element-hq/synapse:v1.147.1"; # https://github.com/element-hq/synapse/pkgs/container/synapse
        network_mode = "service:vpn"; # 8008/tcp
        restart = "unless-stopped";

        volumes =
          [
            "${config.custom.containers.directory}/synapse/data:/data"
            "${config.age.secrets."${config.custom.hostname}/synapse/homeserver.yaml".path}:/data/homeserver.yaml:ro"
          ]
          ++ optionals (!isNull cfg.dataDir) [
            "${cfg.dataDir}/media:/data/media_store"
          ];

        environment = {
          #?? arion-synapse run -- --rm -e SYNAPSE_SERVER_NAME=matrix.example.com -e SYNAPSE_REPORT_STATS=yes synapse generate
          SYNAPSE_CONFIG_PATH = "/data/homeserver.yaml";
        };
      };

      db.service = {
        container_name = "synapse-db";
        env_file = [config.age.secrets."${config.custom.hostname}/synapse/db.env".path];
        image = "postgres:15.13"; # https://hub.docker.com/_/postgres/tags
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/synapse/db:/var/lib/postgresql/data"];
      };

      # https://github.com/element-hq/lk-jwt-service
      jwt.service = {
        container_name = "synapse-jwt";
        env_file = [config.age.secrets."${config.custom.hostname}/synapse/jwt.env".path];
        image = "ghcr.io/element-hq/lk-jwt-service:0.4.1"; # https://github.com/element-hq/lk-jwt-service/pkgs/container/lk-jwt-service
        network_mode = "service:vpn"; # 8888/tcp
        restart = "unless-stopped";
      };

      # https://github.com/element-hq/element-web/blob/develop/docs/install.md#docker
      element.service = {
        container_name = "synapse-element";
        image = "ghcr.io/element-hq/element-web:v1.12.10"; # https://github.com/element-hq/element-web/pkgs/container/element-web
        network_mode = "service:vpn"; # 80/tcp
        restart = "unless-stopped";

        volumes = let
          # https://github.com/element-hq/element-web/blob/develop/docs/config.md
          configuration = pkgs.writeText "config.json" (generators.toJSON {} {
            default_country_code = "US";
            default_server_config."m.homeserver".base_url = "https://matrix.${config.custom.domain}";
            #// default_server_name = config.custom.domain; #!! Requires .well-known
            default_theme = "dark";
            disable_custom_urls = true;
            disable_guests = true;
            element_call.use_exclusively = true;
            permalink_prefix = "https://element.${config.custom.domain}";
            show_labs_settings = true;
          });
        in [
          "${configuration}:/app/config.json:ro"
        ];
      };

      # https://github.com/etkecc/synapse-admin
      # https://github.com/etkecc/synapse-admin/blob/main/docker-compose.yml
      admin.service = {
        container_name = "synapse-admin";
        image = "ghcr.io/etkecc/synapse-admin:v0.11.1-etke53"; # https://github.com/etkecc/synapse-admin/pkgs/container/synapse-admin
        network_mode = "service:vpn"; # 8080/tcp
        restart = "unless-stopped";

        volumes = let
          # https://github.com/etkecc/synapse-admin/blob/main/docs/config.md
          configuration = pkgs.writeText "config.json" (generators.toJSON {} {
            restrictBaseUrl = ["https://matrix.bjork.tech"];
          });
        in [
          "${configuration}:/app/config.json:ro"
        ];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "synapse-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-synapse";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/synapse/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };

    systemd.tmpfiles.settings.synapse = let
      owner = mode: {
        inherit mode;
        user = "991"; # synapse
        group = "991"; # synapse
      };
    in
      {
        "${config.custom.containers.directory}/synapse/data" = {
          d = owner "0700";
          z = owner "0700";
        };
      }
      // optionalAttrs (!isNull cfg.dataDir) {
        "${cfg.dataDir}" = {
          d = owner "0700";
          z = owner "0700";
        };
      };

    age.secrets = listToAttrs (map (name: {
        inherit name;

        value = {
          file = "${inputs.self}/secrets/${name}";
          owner = "991"; # synapse
          group = "991"; # synapse
        };
      })
      [
        "${config.custom.hostname}/synapse/db.env"
        "${config.custom.hostname}/synapse/jwt.env"
        "${config.custom.hostname}/synapse/homeserver.yaml"
      ]);
  };
}
