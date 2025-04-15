{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.dashdot;
in {
  options.custom.containers.dashdot = {
    enable = mkEnableOption "dashdot";
  };

  config = mkIf cfg.enable {
    #?? arion-dashdot pull
    environment.shellAliases.arion-dashdot = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.dashdot.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.dashdot.settings.services = {
      # https://getdashdot.com/
      # https://getdashdot.com/docs/installation/docker-compose
      # https://github.com/MauriceNino/dashdot
      dashdot.service = {
        container_name = "dashdot";
        image = "mauricenino/dashdot:6"; # https://hub.docker.com/r/mauricenino/dashdot/tags
        ports = ["127.0.0.1:3011:3001/tcp"];
        privileged = true;
        restart = "unless-stopped";
        volumes = ["/:/mnt/host:ro"];

        # https://getdashdot.com/docs/configuration/basic
        environment = {
          DASHDOT_ACCEPT_OOKLA_EULA = "true";
          DASHDOT_ALWAYS_SHOW_PERCENTAGES = "true";
          DASHDOT_DISABLE_INTEGRATIONS = "true";
          DASHDOT_ENABLE_CPU_TEMPS = "true";
          DASHDOT_NETWORK_SPEED_AS_BYTES = "true";
          DASHDOT_OVERRIDE_OS = "NixOS ${versions.majorMinor version}";
          DASHDOT_SHOW_HOST = "true";
        };
      };
    };
  };
}
