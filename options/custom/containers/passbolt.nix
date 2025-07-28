{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.passbolt;
in {
  options.custom.containers.passbolt = {
    enable = mkEnableOption "passbolt";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/passbolt/.env" = secret "${config.custom.hostname}/passbolt/.env";
      "${config.custom.hostname}/passbolt/db.env" = secret "${config.custom.hostname}/passbolt/db.env";
    };

    #?? arion-passbolt pull
    environment.shellAliases.arion-passbolt = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.passbolt.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.passbolt.settings.services = {
      # https://www.passbolt.com/
      # https://www.passbolt.com/docs/hosting/install/ce/docker/
      # https://github.com/passbolt/passbolt_api
      # https://github.com/passbolt/passbolt_docker
      # https://github.com/passbolt/passbolt_docker/blob/master/docker-compose/docker-compose-ce-postgresql.yaml
      #?? arion-passbolt exec -- passbolt ./bin/cake passbolt register_user -u <email> -f <first name> -l <last name> -r admin
      passbolt.service = {
        command = ["bash" "-c" "/usr/bin/wait-for.sh -t 0 db:5432 -- /docker-entrypoint.sh"];
        container_name = "passbolt";
        depends_on = ["db"];
        env_file = [config.age.secrets."${config.custom.hostname}/passbolt/.env".path];
        image = "passbolt/passbolt:5.3.2-1-ce-non-root"; # https://hub.docker.com/r/passbolt/passbolt/tags
        ports = ["8181:8080/tcp"]; # 80/tcp for root
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/passbolt/gpg:/etc/passbolt/gpg"
          "${config.custom.containers.directory}/passbolt/jwt:/etc/passbolt/jwt"
        ];
      };

      db.service = {
        container_name = "passbolt-db";
        env_file = [config.age.secrets."${config.custom.hostname}/passbolt/db.env".path];
        image = "postgres:17.5"; # https://hub.docker.com/_/postgres/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/passbolt/db:/var/lib/postgresql/data"];
      };
    };

    #?? arion-passbolt run -- --rm --entrypoint=id passbolt
    systemd.tmpfiles.settings.passbolt = let
      owner = mode: {
        inherit mode;
        user = "33"; # www-data
        group = "33"; # www-data
      };
    in {
      "${config.custom.containers.directory}/passbolt/gpg" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/passbolt/jwt" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };
  };
}
