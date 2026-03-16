{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.arion.ovenmediaengine;
in {
  options.custom.arion.ovenmediaengine = {
    enable = mkEnableOption "ovenmediaengine";
  };

  config = mkIf cfg.enable {
    #?? arion-ovenmediaengine pull
    environment.shellAliases.arion-ovenmediaengine = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.ovenmediaengine.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.ovenmediaengine.settings.services = {
      # https://github.com/AirenSoft/OvenMediaEngine
      # https://docs.ovenmediaengine.com/getting-started/getting-started-with-docker
      ovenmediaengine.service = {
        container_name = "ovenmediaengine";
        env_file = [config.age.secrets."${config.custom.hostname}/ovenmediaengine/.env".path];
        image = "airensoft/ovenmediaengine:v0.20.0"; # https://hub.docker.com/r/airensoft/ovenmediaengine/tags
        restart = "unless-stopped";
        network_mode = "host"; # https://docs.ovenmediaengine.com/getting-started#ports-used-by-default

        volumes = [
          # https://docs.ovenmediaengine.com/configuration
          # https://github.com/AirenSoft/OvenMediaEngine/blob/master/misc/conf_examples/Server.xml
          "${./Server.xml}:/opt/ovenmediaengine/bin/origin_conf/Server.xml:ro"
        ];
      };
    };

    age.secrets =
      mapAttrs (name: value: recursiveUpdate {file = "${inputs.self}/secrets/${name}";} value)
      {
        "${config.custom.hostname}/ovenmediaengine/.env" = {};
      };
  };
}
