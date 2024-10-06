{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.actualbudget;
in {
  options.custom.containers.actualbudget.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    #?? arion-actualbudget pull
    environment.shellAliases.arion-actualbudget = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.actualbudget.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.actualbudget = {
      serviceName = "actualbudget";

      settings.services = {
        actualbudget.service = {
          container_name = "actualbudget";
          image = "actualbudget/actual-server:24.9.0";
          ports = ["5006:5006"];
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/actualbudget/data:/data"];
          # TODO: Set up trusted proxies
        };
      };
    };
  };
}
