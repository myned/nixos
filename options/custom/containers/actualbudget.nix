{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.actualbudget;
in {
  options.custom.containers.actualbudget = {
    enable = mkEnableOption "actualbudget";
  };

  config = mkIf cfg.enable {
    #?? arion-actualbudget pull
    environment.shellAliases.arion-actualbudget = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.actualbudget.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.actualbudget.settings.services = {
      actualbudget.service = {
        container_name = "actualbudget";
        image = "ghcr.io/actualbudget/actual:25.8.0"; # https://github.com/actualbudget/actual/pkgs/container/actual
        ports = ["5006:5006/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/actualbudget/data:/data"];
      };
    };
  };
}
