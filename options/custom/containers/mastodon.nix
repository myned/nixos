{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.mastodon;
in {
  options.custom.containers.mastodon.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/mastodon/.env" = secret "${config.custom.profile}/mastodon/.env";
      "${config.custom.profile}/mastodon/db.env" = secret "${config.custom.profile}/mastodon/db.env";
    };

    #?? arion-mastodon pull
    environment.shellAliases.arion-mastodon = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.mastodon.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.mastodon.settings.services = {
      # https://github.com/linuxserver/docker-mastodon
      # https://github.com/mastodon/mastodon/blob/main/docker-compose.yml
      mastodon.service = {
        container_name = "mastodon";
        env_file = [config.age.secrets."${config.custom.profile}/mastodon/.env".path];
        image = "lscr.io/linuxserver/mastodon:4.3.3";
        ports = ["3000:443/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/mastodon/config:/config"];

        depends_on = [
          "cache"
          "db"
        ];
      };

      cache.service = {
        container_name = "mastodon-cache";
        image = "redis:latest";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/mastodon/cache:/data"];
      };

      db.service = {
        container_name = "mastodon-db";
        env_file = [config.age.secrets."${config.custom.profile}/mastodon/db.env".path];
        image = "postgres:15";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/mastodon/db:/var/lib/postgresql/data"];
      };
    };
  };
}
