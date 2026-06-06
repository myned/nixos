{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.prometheus;
in {
  options.custom.services.prometheus = {
    enable = mkEnableOption "prometheus";

    exporter = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://prometheus.io/
    # https://wiki.nixos.org/wiki/Prometheus
    services.prometheus = {
      # https://prometheus.io/docs/guides/node-exporter/
      # https://github.com/prometheus/node_exporter
      exporters.node = {
        enable = true;
        listenAddress = config.custom.services.tailscale.ipv4;
        openFirewall = true; # 9100/tcp
      };
    };
  };
}
