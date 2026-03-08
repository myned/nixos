{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.livekit;
  containerCfg = config.containers.livekit;
  hostCfg = config;
in {
  options.custom.containers.livekit = {
    enable = mkEnableOption "livekit";
    enableIngress = mkEnableOption "livekit-ingress";
  };

  config = mkIf cfg.enable {
    containers.livekit = {
      privateNetwork = false;

      config = {
        # https://wiki.nixos.org/wiki/Matrix#Livekit
        services.livekit = {
          enable = true;
          openFirewall = true;
          keyFile = mkIf containerCfg.enableAgenix containerCfg.config.age.secrets."${hostCfg.custom.hostname}/livekit/keys.yaml".path;
          redis.host = "localhost";
          redis.port = 6379; # TCP

          # https://docs.livekit.io/transport/self-hosting/deployment/
          # https://github.com/livekit/livekit/blob/master/config-sample.yaml
          settings = {
            ingress.rtmp_base_url = "rtmp://stream.${hostCfg.custom.domain}/live";
            ingress.whip_base_url = "https://stream.${hostCfg.custom.domain}/whip";
            log_level = "info";
            port = 7880; # TCP
            room.auto_create = false;
            rtc.port_range_start = 50000; # UDP
            rtc.port_range_end = 51000; # UDP
            #// rtc.use_external_ip = true;
            #// turn.enabled = true;
            #// turn.udp_port = 443; # UDP
          };
        };

        # https://docs.livekit.io/transport/media/ingress-egress/ingress/
        # https://docs.livekit.io/transport/self-hosting/ingress/
        services.livekit.ingress = mkIf cfg.enableIngress {
          enable = true;
          openFirewall.rtc = true;
          openFirewall.rtmp = true;
          openFirewall.whip = true;
          environmentFile = mkIf containerCfg.enableAgenix containerCfg.config.age.secrets."${hostCfg.custom.hostname}/livekit/ingress.env".path;

          # https://github.com/livekit/ingress?tab=readme-ov-file#config
          settings = {
            rtc_config = containerCfg.config.services.livekit.settings.rtc;
            rtmp_port = 1935; # TCP
            whip_port = 8080; # TCP
            cpu_cost.rtmp_cpu_cost = 2;
            cpu_cost.whip_cpu_cost = 2;
            cpu_cost.url_cpu_cost = 2;
            cpu_cost.whip_bypass_transcoding_cpu_cost = 0.1; # Passthrough
            ws_url = "ws://localhost:${toString containerCfg.config.services.livekit.settings.port}";
          };
        };

        systemd.services = {
          livekit.serviceConfig.User = "livekit"; # Statically assign DynamicUser
          livekit-ingress.serviceConfig.User = mkIf cfg.enableIngress "livekit-ingress";
        };

        age.secrets = mkIf containerCfg.enableAgenix (mapAttrs (name: value: recursiveUpdate {file = "${inputs.self}/secrets/${name}";} value)
          {
            "${hostCfg.custom.hostname}/livekit/keys.yaml".owner = "livekit";
            "${hostCfg.custom.hostname}/livekit/ingress.env".owner = mkIf cfg.enableIngress "livekit-ingress";
          });
      };
    };
  };
}
