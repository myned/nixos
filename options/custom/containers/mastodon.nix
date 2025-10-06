{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.mastodon;
in {
  options.custom.containers.mastodon = {
    enable = mkEnableOption "mastodon";
  };

  config = mkIf cfg.enable {
    #?? arion-mastodon pull
    environment.shellAliases.arion-mastodon = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.mastodon.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.mastodon.settings.services = {
      # https://github.com/glitch-soc/mastodon
      # https://github.com/linuxserver/docker-mastodon
      # https://github.com/mastodon/mastodon/blob/main/docker-compose.yml
      mastodon.service = {
        container_name = "mastodon";
        depends_on = ["cache" "db"];
        env_file = [config.age.secrets."${config.custom.hostname}/mastodon/.env".path];
        image = "ghcr.io/linuxserver/mastodon:4.4.5-glitch"; # https://github.com/linuxserver/docker-mastodon/pkgs/container/mastodon
        ports = ["3000:443/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/mastodon/config:/config"];
      };

      cache.service = {
        container_name = "mastodon-cache";
        image = "redis:8.0.3"; # https://hub.docker.com/_/redis/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/mastodon/cache:/data"];
      };

      db.service = {
        container_name = "mastodon-db";
        env_file = [config.age.secrets."${config.custom.hostname}/mastodon/db.env".path];
        image = "postgres:15.13"; # https://hub.docker.com/_/postgres/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/mastodon/db:/var/lib/postgresql/data"];
      };
    };

    age.secrets = listToAttrs (map (name: {
        inherit name;
        value = {file = "${inputs.self}/secrets/${name}";};
      })
      [
        "${config.custom.hostname}/mastodon/.env"
        "${config.custom.hostname}/mastodon/db.env"
      ]);
  };
}
