{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.wiki;
in {
  options.custom.containers.wiki = {
    enable = mkEnableOption "wiki";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/wiki/.env" = secret "${config.custom.profile}/wiki/.env";
      "${config.custom.profile}/wiki/db.env" = secret "${config.custom.profile}/wiki/db.env";
    };

    #?? arion-wiki pull
    environment.shellAliases.arion-wiki = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.wiki.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.wiki.settings.services = {
      # https://js.wiki/
      # https://docs.requarks.io/
      # https://github.com/Requarks/wiki
      wiki.service = {
        container_name = "wiki";
        depends_on = ["db"];
        env_file = [config.age.secrets."${config.custom.profile}/wiki/.env".path];
        image = "ghcr.io/requarks/wiki:2";
        ports = ["3303:3000"];
        restart = "unless-stopped";
      };

      db.service = {
        container_name = "wiki-db";
        env_file = [config.age.secrets."${config.custom.profile}/wiki/db.env".path];
        image = "postgres:15";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/wiki/db:/var/lib/postgresql/data"];
      };
    };
  };
}
