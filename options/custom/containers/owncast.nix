{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.owncast;
in {
  options.custom.containers.owncast.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    #?? arion-owncast pull
    environment.shellAliases.arion-owncast = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.owncast.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.owncast.settings.services = {
      owncast.service = {
        container_name = "owncast";
        image = "owncast/owncast:0.1.3";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/owncast/data:/app/data"];

        ports = [
          "1935:1935"
          "127.0.0.1:8800:8080"
        ];
      };
    };
  };
}
