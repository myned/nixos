{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.miniflux;
in {
  options.custom.containers.miniflux = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/miniflux/.env" = secret "${config.custom.profile}/miniflux/.env";
      "${config.custom.profile}/miniflux/db.env" = secret "${config.custom.profile}/miniflux/db.env";
    };

    #?? arion-miniflux pull
    environment.shellAliases.arion-miniflux = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.miniflux.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.miniflux.settings.services = {
      # https://github.com/miniflux/v2
      # https://miniflux.app/docs/docker.html
      miniflux.service = {
        container_name = "miniflux";
        depends_on = ["db"];
        env_file = [config.age.secrets."${config.custom.profile}/miniflux/.env".path];
        image = "miniflux/miniflux:2.2.6";
        ports = ["127.0.0.1:8808:8080/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/miniflux/data:/data"];
      };

      db.service = {
        container_name = "miniflux-db";
        env_file = [config.age.secrets."${config.custom.profile}/miniflux/db.env".path];
        image = "postgres:17";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/miniflux/db:/var/lib/postgresql/data"];
      };
    };
  };
}
