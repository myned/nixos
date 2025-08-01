{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.ovenmediaengine;
in {
  options.custom.containers.ovenmediaengine = {
    enable = mkEnableOption "ovenmediaengine";

    bind = mkOption {
      default = config.custom.services.tailscale.ipv4;
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    #?? arion-ovenmediaengine pull
    environment.shellAliases.arion-ovenmediaengine = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.ovenmediaengine.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.ovenmediaengine.settings.services = {
      # https://github.com/AirenSoft/OvenMediaEngine
      # https://docs.ovenmediaengine.com/getting-started/getting-started-with-docker
      ovenmediaengine.service = {
        container_name = "ovenmediaengine";
        image = "airensoft/ovenmediaengine:0.18.0"; # https://hub.docker.com/r/airensoft/ovenmediaengine/tags
        restart = "unless-stopped";

        ports = [
          "${cfg.bind}:3333:3333/tcp" # LLHLS / WebRTC Signaling
          "${cfg.bind}:3333:3333/udp" # WebRTC Signaling
          "${cfg.bind}:1935:1935/tcp" # RTMP
          "${cfg.bind}:10000:10000/udp" # WebRTC Candidate
        ];

        volumes = [
          # https://docs.ovenmediaengine.com/configuration
          # https://github.com/AirenSoft/OvenMediaEngine/blob/master/misc/conf_examples/Server.xml
          "${./Server.xml}:/opt/ovenmediaengine/bin/origin_conf/Server.xml:ro"
        ];
      };
    };
  };
}
