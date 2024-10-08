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
      "${config.custom.profile}/searxng/.env" = secret "${config.custom.profile}/searxng/.env";
    };

    #?? arion-searxng pull
    environment.shellAliases.arion-searxng = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.searxng.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.searxng.settings.services = {
      # https://github.com/searxng/searxng
      # https://github.com/searxng/searxng-docker
      searxng.service = {
        container_name = "searxng";
        depends_on = ["cache"];
        env_file = [config.age.secrets."${config.custom.profile}/searxng/.env".path];
        image = "searxng/searxng:latest";
        ports = ["127.0.0.1:8000:8080"];
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
        image = "valkey/valkey:7-alpine";
        restart = "unless-stopped";
      };
    };
  };
}
