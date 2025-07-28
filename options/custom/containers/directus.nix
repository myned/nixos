{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.directus;
in {
  options.custom.containers.directus = {
    enable = mkEnableOption "directus";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/directus/.env" = secret "${config.custom.hostname}/directus/.env";
    };

    #?? arion-directus pull
    environment.shellAliases.arion-directus = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.directus.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.directus.settings.services = {
      # https://github.com/directus/directus
      # https://directus.io/
      # https://directus.io/docs/getting-started/create-a-project#docker-installation
      # https://directus.io/docs/self-hosting/overview
      directus.service = {
        container_name = "directus";
        env_file = [config.age.secrets."${config.custom.hostname}/directus/.env".path];
        image = "directus/directus:11.9.3"; # https://hub.docker.com/r/directus/directus/tags
        ports = ["${config.custom.services.tailscale.ipv4}:8055:8055/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/directus/db:/directus/database"
          "${config.custom.containers.directory}/directus/uploads:/directus/uploads"
          "${config.custom.containers.directory}/directus/extensions:/directus/extensions"
        ];
      };
    };

    #?? arion-directus run -- --rm --entrypoint='id' directus
    systemd.tmpfiles.settings.directus = let
      owner = mode: {
        inherit mode;
        user = "1000"; # node
        group = "1000"; # node
      };
    in {
      "${config.custom.containers.directory}/directus/db" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/directus/uploads" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/directus/extensions" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };
  };
}
