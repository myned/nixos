{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.gatus;
in {
  options.custom.containers.gatus = {
    enable = mkEnableOption "gatus";

    settings = mkOption {
      default = null;
      description = "Configuration file, generated to YAML";

      example = {
        storage = {
          type = "sqlite";
          path = "/data/data.db";
        };

        endpoints = [
          {
            name = "example";
            url = "https://example.org";
            interval = "30s";
            conditions = ["[STATUS] == 200"];
          }
        ];
      };

      type = with types; nullOr attrs;
    };
  };

  config = mkIf cfg.enable {
    #?? arion-gatus pull
    environment.shellAliases.arion-gatus = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.gatus.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.gatus.settings.services = {
      # https://github.com/TwiN/gatus
      # https://github.com/TwiN/gatus/blob/master/.examples/docker-compose-sqlite-storage/docker-compose.yml
      gatus.service = {
        container_name = "gatus";
        depends_on = ["vpn"];
        image = "ghcr.io/twin/gatus:v5.24.2"; # https://github.com/TwiN/gatus/pkgs/container/gatus
        network_mode = "service:vpn"; # 8080/tcp
        restart = "unless-stopped";

        volumes =
          [
            "${config.custom.containers.directory}/gatus/data:/data"
          ]
          ++ optionals (!isNull cfg.settings) [
            # https://github.com/TwiN/gatus/blob/master/.examples/docker-compose-sqlite-storage/config/config.yaml
            "${pkgs.writeText "config.yaml" (generators.toYAML {} cfg.settings)}:/config/config.yaml:ro"
          ];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "gatus-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-gatus";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        ports = ["8484:8080/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/gatus/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };
  };
}
