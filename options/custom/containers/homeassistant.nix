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

    virtualisation.arion.projects.homeassistant = {
      serviceName = "homeassistant";

      settings.services = {
        homeassistant.service = {
          container_name = "homeassistant";
          image = "homeassistant/home-assistant:2024.9.1";
          ports = ["8123:8123"];
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/homeassistant/config:/config"];
        };
      };
    };
  };
}
