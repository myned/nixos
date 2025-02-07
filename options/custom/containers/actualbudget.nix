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

    virtualisation.arion.projects.actualbudget.settings.services = {
      actualbudget.service = {
        container_name = "actualbudget";
        image = "actualbudget/actual-server:25.2.1";
        ports = ["127.0.0.1:5006:5006/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/actualbudget/data:/data"];
      };
    };
  };
}
