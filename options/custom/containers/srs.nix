{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.srs;
in {
  options.custom.containers.srs = {
    enable = mkEnableOption "srs";
  };

  config = mkIf cfg.enable {
    #?? arion-srs pull
    environment.shellAliases.arion-srs = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.srs.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.srs.settings.services = {
      # https://ossrs.io/lts/en-us/
      # https://github.com/ossrs/srs
      srs.service = {
        container_name = "srs";
        image = "ossrs/srs:6"; # https://hub.docker.com/r/ossrs/srs/tags
        restart = "unless-stopped";

        ports = [
          "127.0.0.1:1985:1985/tcp" # HTTP API
          "127.0.0.1:8800:8080/tcp" # HTTP
          "${config.custom.services.tailscale.ip}:1935:1935/tcp" # RTMP
          "${config.custom.services.tailscale.ip}:8000:8000/udp" # WebRTC
          "${config.custom.services.tailscale.ip}:10080:10080/udp" # SRT
        ];

        # https://github.com/ossrs/srs/blob/develop/trunk/conf/full.conf
        environment = {
          # https://ossrs.io/lts/en-us/docs/v6/doc/webrtc#config-candidate
          CANDIDATE = toString config.custom.services.tailscale.ip;

          SRS_HTTP_API_ENABLED = "on";
          SRS_HTTP_SERVER_ENABLED = "on";
          SRS_RTC_SERVER_ENABLED = "on";
          SRS_SRT_SERVER_ENABLED = "on";
        };
      };
    };
  };
}
