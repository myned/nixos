{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.ghost;
in {
  options.custom.containers.ghost = {
    enable = mkEnableOption "ghost";

    develop = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/ghost/.env" = secret "${config.custom.profile}/ghost/.env";
      "${config.custom.profile}/ghost/db.env" = secret "${config.custom.profile}/ghost/db.env";
    };

    #?? arion-ghost pull
    environment.shellAliases.arion-ghost = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.ghost.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.ghost.settings.services = {
      # https://ghost.org/
      # https://github.com/tryghost/ghost/
      # https://hub.docker.com/_/ghost/
      #?? https://<domain>/ghost/
      ghost.service = let
        ip =
          if cfg.develop
          then "127.0.0.1"
          else config.custom.services.tailscale.ipv4;
      in {
        container_name = "ghost";
        depends_on = ["db"];
        env_file = [config.age.secrets."${config.custom.profile}/ghost/.env".path];
        image = "ghost:5";
        ports = ["${ip}:2368:2368/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/ghost/data:/var/lib/ghost/content"];

        environment = optionalAttrs cfg.develop {
          NODE_ENV = "development";
        };
      };

      db.service = {
        container_name = "ghost-db";
        env_file = [config.age.secrets."${config.custom.profile}/ghost/db.env".path];
        image = "mysql:8";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/ghost/db:/var/lib/mysql"];
      };
    };
  };
}
