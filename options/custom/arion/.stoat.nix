{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.arion.stoat;
in {
  options.custom.arion.stoat = {
    enable = mkEnableOption "stoat";
  };

  config = mkIf cfg.enable {
    #?? arion-stoat pull
    environment.shellAliases.arion-stoat = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.stoat.settings.out.dockerComposeYaml}";

    # https://github.com/stoatchat/stoatchat/blob/main/compose.yml
    # https://github.com/stoatchat/self-hosted/blob/main/compose.yml
    # https://github.com/stoatchat/self-hosted/blob/main/generate_config.sh
    virtualisation.arion.projects.stoat.settings.services = {
      # https://github.com/stoatchat/self-hosted
      # https://github.com/stoatchat/stoatchat
      api.service = {
        container_name = "stoat-api";
        image = "ghcr.io/stoatchat/api:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/api
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];

        depends_on = {
          db.condition = "service_healthy";
          cache.condition = "service_started";
          mq.condition = "service_healthy";
          vpn.condition = "service_started";
        };
      };

      events.service = {
        container_name = "stoat-events";
        image = "ghcr.io/stoatchat/events:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/events
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];

        depends_on = {
          db.condition = "service_healthy";
          cache.condition = "service_started";
          vpn.condition = "service_started";
        };
      };

      fileserver.service = {
        container_name = "stoat-fileserver";
        image = "ghcr.io/stoatchat/file-server:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/file-server
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];

        depends_on = {
          db.condition = "service_healthy";
          init.condition = "service_started";
          vpn.condition = "service_started";
        };
      };

      proxy.service = {
        container_name = "stoat-proxy";
        depends_on = ["vpn"];
        image = "ghcr.io/stoatchat/proxy:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/proxy
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];
      };

      gifbox.service = {
        container_name = "stoat-gifbox";
        depends_on = ["vpn"];
        image = "ghcr.io/stoatchat/gifbox:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/gifbox
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];
      };

      crond.service = {
        container_name = "stoat-crond";
        image = "ghcr.io/stoatchat/crond:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/crond
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];

        depends_on = {
          db.condition = "service_healthy";
          store.condition = "service_started";
          vpn.condition = "service_started";
        };
      };

      pushd.service = {
        container_name = "stoat-pushd";
        image = "ghcr.io/stoatchat/pushd:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/pushd
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];

        depends_on = {
          db.condition = "service_healthy";
          cache.condition = "service_started";
          mq.condition = "service_healthy";
          vpn.condition = "service_started";
        };
      };

      voiceingress.service = {
        container_name = "stoat-voiceingress";
        image = "ghcr.io/stoatchat/voice-ingress:v0.11.5"; # https://github.com/orgs/stoatchat/packages/container/package/voice-ingress
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/Revolt.toml".path}:/Revolt.toml:ro"];
        depends_on = {
          db.condition = "service_healthy";
          mq.condition = "service_healthy";
          vpn.condition = "service_started";
        };
      };

      # https://github.com/stoatchat/livekit-server
      livekit.service = {
        command = "--config=/etc/livekit.yaml";
        container_name = "stoat-livekit";
        depends_on = ["vpn"];
        image = "ghcr.io/stoatchat/livekit-server:v1.9.6"; # https://github.com/stoatchat/livekit-server/pkgs/container/livekit-server
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/stoat/livekit.yaml".path}:/etc/livekit.yaml:ro"];
      };

      # https://github.com/stoatchat/for-web
      web.service = {
        container_name = "stoat-web";
        depends_on = ["vpn"];
        # TODO: Use official image when livekit is supported
        #// image = "ghcr.io/stoatchat/for-web:addb6b7"; # https://github.com/stoatchat/for-web/pkgs/container/for-web
        image = "baptisterajaut/stoatchat-web:dev";
        network_mode = "service:vpn";
        restart = "unless-stopped";

        # https://github.com/stoatchat/self-hosted/blob/b0cb09c2ecc864f13a8f2745d609f00a5c9704ea/generate_config.sh#L13
        environment = {
          HOSTNAME = "https://stoat.${config.custom.domain}";
          REVOLT_PUBLIC_URL = "https://stoat.${config.custom.domain}/api";
          VITE_API_URL = "https://stoat.${config.custom.domain}/api";
          VITE_WS_URL = "wss://stoat.${config.custom.domain}/ws";
          VITE_MEDIA_URL = "https://stoat.${config.custom.domain}/media";
          VITE_PROXY_URL = "https://stoat.${config.custom.domain}/proxy";
        };
      };

      db.service = {
        container_name = "stoat-db";
        depends_on = ["vpn"];
        image = "docker.io/mongo:8.2.5"; # https://hub.docker.com/_/mongo/tags
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.custom.arion.directory}/stoat/db:/data/db"];

        healthcheck = {
          test = ["CMD-SHELL" "echo" "db.runCommand('ping').ok" "|" "mongosh" "localhost:27017/test" "--quiet"];
          start_period = "10s";
          interval = "10s";
          timeout = "10s";
          retries = 5;
        };
      };

      cache.service = {
        container_name = "stoat-cache";
        depends_on = ["vpn"];
        image = "eqalpha/keydb:${pkgs.stdenv.hostPlatform.linuxArch}_v6.3.4"; # https://hub.docker.com/r/eqalpha/keydb/tags
        network_mode = "service:vpn";
        restart = "unless-stopped";
      };

      mq.service = {
        container_name = "stoat-mq";
        depends_on = ["vpn"];
        env_file = [config.age.secrets."${config.custom.hostname}/stoat/mq.env".path];
        image = "docker.io/rabbitmq:4.2.4"; # https://hub.docker.com/_/rabbitmq/tags
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.custom.arion.directory}/stoat/mq:/var/lib/rabbitmq"];

        healthcheck = {
          test = ["CMD" "rabbitmq-diagnostics" "-q" "ping"];
          start_period = "20s";
          interval = "10s";
          timeout = "10s";
          retries = 3;
        };
      };

      store.service = {
        command = "server /data";
        container_name = "stoat-store";
        depends_on = ["vpn"];
        env_file = [config.age.secrets."${config.custom.hostname}/stoat/store.env".path];
        image = "docker.io/minio/minio:RELEASE.2025-09-07T16-13-09Z"; # https://hub.docker.com/r/minio/minio/tags
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.custom.arion.directory}/stoat/store:/data"];
      };

      init.service = {
        container_name = "stoat-init";
        depends_on = ["store" "vpn"];
        env_file = [config.age.secrets."${config.custom.hostname}/stoat/store.env".path];
        image = "docker.io/minio/mc:RELEASE.2025-08-13T08-35-41Z"; # https://hub.docker.com/r/minio/mc/tags
        network_mode = "service:vpn";

        entrypoint = ''
          /bin/sh -c "
            while ! /usr/bin/mc ready minio; do
              /usr/bin/mc alias set minio http://localhost:9000 '$MINIO_ROOT_USER' '$MINIO_ROOT_PASSWORD';
              echo 'Waiting minio...' && sleep 1;
            done;
            /usr/bin/mc mb minio/stoat-uploads;
            exit 0;
          "
        '';
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "stoat-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-stoat";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.arion.directory}/stoat/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };

    age.secrets = listToAttrs (map (name: {
        inherit name;

        value = {
          file = "${inputs.self}/secrets/${name}";
          owner = "65532"; # nonroot
          group = "65532"; # nonroot
        };
      })
      [
        "${config.custom.hostname}/stoat/mq.env"
        "${config.custom.hostname}/stoat/store.env"
        "${config.custom.hostname}/stoat/livekit.yaml"
        "${config.custom.hostname}/stoat/Revolt.toml"
      ]);
  };
}
