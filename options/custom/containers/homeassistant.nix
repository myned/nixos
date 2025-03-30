{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.homeassistant;
in {
  options.custom.containers.homeassistant.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    #?? arion-homeassistant pull
    environment.shellAliases.arion-homeassistant = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.homeassistant.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.homeassistant.settings.services = {
      homeassistant.service = {
        container_name = "homeassistant";
        image = "homeassistant/home-assistant:2025.3";
        ports = ["8123:8123/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/homeassistant/config:/config"];
      };
    };
  };
}
