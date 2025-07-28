{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.wikijs;
in {
  options.custom.containers.wikijs = {
    enable = mkEnableOption "wikijs";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/wikijs/.env" = secret "${config.custom.hostname}/wikijs/.env";
      "${config.custom.hostname}/wikijs/db.env" = secret "${config.custom.hostname}/wikijs/db.env";
    };

    #?? arion-wikijs pull
    environment.shellAliases.arion-wikijs = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.wikijs.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.wikijs.settings.services = {
      # https://js.wiki/
      # https://docs.requarks.io/
      # https://github.com/Requarks/wiki
      wikijs.service = {
        container_name = "wikijs";
        depends_on = ["db"];
        env_file = [config.age.secrets."${config.custom.hostname}/wikijs/.env".path];
        image = "ghcr.io/requarks/wiki:2.5.307";
        ports = ["3303:3000/tcp"]; # https://github.com/requarks/wiki/pkgs/container/wiki
        restart = "unless-stopped";
      };

      db.service = {
        container_name = "wikijs-db";
        env_file = [config.age.secrets."${config.custom.hostname}/wikijs/db.env".path];
        image = "postgres:15.13"; # https://hub.docker.com/_/postgres/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/wikijs/db:/var/lib/postgresql/data"];
      };
    };
  };
}
