{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.searxng;
in {
  options.custom.containers.searxng.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/searxng/.env" = secret "${config.custom.hostname}/searxng/.env";
    };

    #?? arion-searxng pull
    environment.shellAliases.arion-searxng = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.searxng.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.searxng.settings.services = {
      # https://github.com/searxng/searxng
      # https://github.com/searxng/searxng-docker
      searxng.service = {
        container_name = "searxng";
        depends_on = ["cache"];
        env_file = [config.age.secrets."${config.custom.hostname}/searxng/.env".path];
        image = "searxng/searxng:2025.7.27-f04c273"; # https://hub.docker.com/r/searxng/searxng/tags
        ports = ["8888:8080/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${./limiter.toml}:/etc/searxng/limiter.toml"
          "${./settings.yml}:/etc/searxng/settings.yml"
        ];
      };

      # https://github.com/valkey-io/valkey
      cache.service = {
        command = "valkey-server --save 60 1 --loglevel warning";
        container_name = "searxng-cache";
        image = "valkey/valkey:7";
        restart = "unless-stopped";
      };
    };
  };
}
