{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.stremio;
in {
  options.custom.containers.stremio = {
    enable = mkEnableOption "stremio";
  };

  config = mkIf cfg.enable {
    #?? arion-stremio pull
    environment.shellAliases.arion-stremio = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.stremio.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.stremio.settings.services = {
      # https://www.stremio.com/
      # https://github.com/tsaridas/stremio-docker
      stremio.service = {
        container_name = "stremio";
        image = "tsaridas/stremio-docker:v1.2.3"; # https://hub.docker.com/r/tsaridas/stremio-docker/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/stremio/data:/root/.stremio-server"];

        ports = [
          "8470:8080/tcp"
          "11470:11470/tcp"
        ];

        environment = {
          # TODO: Use internal server when implemented
          # https://github.com/tsaridas/stremio-docker/issues/78
          DISABLE_CACHING = 1;
          SERVER_URL = "https://tv-api.vpn.${config.custom.domain}/";
          WEBUI_LOCATION = "https://tv.vpn.${config.custom.domain}/";
        };
      };
    };
  };
}
