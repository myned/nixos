{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.arion.homeassistant;
in {
  options.custom.arion.homeassistant.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    #?? arion-homeassistant pull
    environment.shellAliases.arion-homeassistant = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.homeassistant.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.homeassistant.settings.services = {
      homeassistant.service = {
        container_name = "homeassistant";
        image = "homeassistant/home-assistant:2025.7"; # https://hub.docker.com/r/homeassistant/home-assistant/tags
        network_mode = "host"; # 8123/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.arion.directory}/homeassistant/config:/config"];
      };
    };
  };
}
