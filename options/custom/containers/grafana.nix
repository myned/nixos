{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.grafana;
in {
  options.custom.containers.grafana = {
    enable = mkEnableOption "grafana";

    prometheus = {
      enable = mkOption {
        default = true;
        type = types.bool;
      };

      # https://prometheus.io/docs/prometheus/latest/configuration/configuration/
      settings = mkOption {
        default = {
          scrape_configs = [
            {
              # https://prometheus.io/docs/guides/node-exporter/#configuring-your-prometheus-instances
              job_name = "node";
              scrape_interval = "5s";
              static_configs = [{targets = cfg.prometheus.targets;}];
            }
          ];
        };

        type = types.attrs;
      };

      targets = mkOption {
        default = ["myne:9100" "mypi3:9100"];
        type = with types; listOf str;
      };
    };
  };

  config = mkIf cfg.enable {
    #?? arion-grafana pull
    environment.shellAliases.arion-grafana = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.grafana.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.grafana.settings = {
      services = {
        # https://github.com/grafana/grafana
        # https://grafana.com/
        # https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/
        grafana.service = {
          container_name = "grafana";
          depends_on = ["vpn"];
          image = "grafana/grafana-oss:latest"; # https://hub.docker.com/r/grafana/grafana-oss/tags
          network_mode = "service:vpn"; # 3000/tcp
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/grafana/data:/var/lib/grafana"];

          # https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/
          environment = {
            GF_PLUGINS_PREINSTALL_DISABLED = "true";
          };
        };

        # https://github.com/prometheus/prometheus
        # https://prometheus.io/
        # https://prometheus.io/docs/prometheus/latest/installation/
        # https://grafana.com/docs/grafana/latest/datasources/prometheus/configure-prometheus-data-source/
        prometheus.service = mkIf cfg.prometheus.enable {
          container_name = "grafana-prometheus";
          image = "quay.io/prometheus/prometheus:latest"; # https://quay.io/repository/prometheus/prometheus?tab=tags
          network_mode = "service:vpn"; # 9090/tcp
          restart = "unless-stopped";

          volumes = [
            "${pkgs.writeText "prometheus.yml" (generators.toYAML {} cfg.prometheus.settings)}:/etc/prometheus/prometheus.yml"
            "${config.custom.containers.directory}/grafana/prometheus/data:/prometheus"
          ];
        };

        # https://tailscale.com/kb/1282/docker
        vpn.service = {
          container_name = "grafana-vpn";
          devices = ["/dev/net/tun:/dev/net/tun"];
          env_file = [config.age.secrets."common/tailscale/container.env".path];
          hostname = "grafana";
          image = "ghcr.io/tailscale/tailscale:latest"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/grafana/vpn:/var/lib/tailscale"];

          capabilities = {
            NET_ADMIN = true;
          };
        };
      };
    };

    # https://github.com/grafana/grafana/blob/main/packaging/docker/custom/Dockerfile
    #?? arion-grafana run -- --rm --entrypoint='id grafana' grafana
    systemd.tmpfiles.settings.grafana = let
      owner = mode: {
        inherit mode;
        user = "472"; # grafana
        group = "472"; # grafana
      };
    in {
      "${config.custom.containers.directory}/grafana/data" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };

    # https://github.com/prometheus/prometheus/blob/main/Dockerfile
    #?? arion-prometheus run -- --rm --entrypoint='id nobody' prometheus
    systemd.tmpfiles.settings.prometheus = let
      owner = mode: {
        inherit mode;
        user = "65534"; # nobody
        group = "65534"; # nobody
      };
    in
      mkIf cfg.prometheus.enable {
        "${config.custom.containers.directory}/grafana/prometheus/data" = {
          d = owner "0700"; # -rwx------
          z = owner "0700"; # -rwx------
        };
      };
  };
}
