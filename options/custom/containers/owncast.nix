{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.owncast;
in {
  options.custom.containers.owncast = {
    enable = mkEnableOption "owncast";
  };

  config = mkIf cfg.enable {
    #?? arion-owncast pull
    environment.shellAliases.arion-owncast = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.owncast.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.owncast.settings.services = {
      owncast.service = {
        container_name = "owncast";
        image = "owncast/owncast:0.2.3"; # https://hub.docker.com/r/owncast/owncast/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/owncast/data:/app/data"];

        ports = [
          "8800:8080/tcp" # HTTP
          "${config.custom.services.tailscale.ipv4}:1935:1935/tcp" # RTMP
        ];
      };
    };
  };
}
