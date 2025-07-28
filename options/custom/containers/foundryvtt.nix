{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.foundryvtt;
in {
  options.custom.containers.foundryvtt.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/foundryvtt/.env" = secret "${config.custom.hostname}/foundryvtt/.env";
    };

    #?? arion-foundryvtt pull
    environment.shellAliases.arion-foundryvtt = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.foundryvtt.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.foundryvtt.settings.services = {
      foundryvtt.service = {
        container_name = "foundryvtt";
        env_file = [config.age.secrets."${config.custom.hostname}/foundryvtt/.env".path];
        image = "felddy/foundryvtt:12.343.0"; # https://hub.docker.com/r/felddy/foundryvtt/tags
        ports = ["30000:30000/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/foundryvtt/data:/data"];
      };
    };
  };
}
