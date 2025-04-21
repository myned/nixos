{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.forgejo;
in {
  options.custom.containers.forgejo = {
    enable = mkEnableOption "forgejo";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/forgejo/.env" = secret "${config.custom.profile}/forgejo/.env";
      "${config.custom.profile}/forgejo/db.env" = secret "${config.custom.profile}/forgejo/db.env";
    };

    #?? arion-forgejo pull
    environment.shellAliases.arion-forgejo = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.forgejo.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.forgejo.settings.services = {
      # https://codeberg.org/forgejo/forgejo
      # https://forgejo.org/docs/latest/admin/
      #?? arion-forgejo exec -- forgejo sudo -u git forgejo admin user create --username <username> --random-password --email <email> --admin
      forgejo.service = {
        container_name = "forgejo";
        depends_on = ["db"];
        env_file = [config.age.secrets."${config.custom.profile}/forgejo/.env".path];
        image = "code.forgejo.org/forgejo/forgejo:11"; # https://code.forgejo.org/forgejo/forgejo
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/forgejo/data:/data"];

        ports = [
          "127.0.0.1:3333:3000/tcp"
          "22:2222/tcp"
        ];
      };

      db.service = {
        container_name = "forgejo-db";
        env_file = [config.age.secrets."${config.custom.profile}/forgejo/db.env".path];
        image = "postgres:15";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/forgejo/db:/var/lib/postgresql/data"];
      };

      # Docker-in-Docker runner
      # https://forgejo.org/docs/next/admin/runner-installation/#oci-image-installation
      # https://code.forgejo.org/forgejo/runner/src/branch/main/examples/docker-compose/compose-forgejo-and-runner.yml
      dind.service = {
        # BUG: Insecure socket deprecation warning despite D-in-D usecase
        # https://github.com/docker/for-linux/issues/1313
        command = ["dockerd" "--host" "tcp://0.0.0.0:2375" "--tls=false"];
        container_name = "forgejo-dind";
        image = "code.forgejo.org/oci/docker:dind"; # https://code.forgejo.org/oci/-/packages/container/docker/dind
        privileged = true;
        restart = "unless-stopped";
      };

      # https://forgejo.org/docs/next/admin/runner-installation/#standard-registration
      #?? arion-forgejo run -- runner forgejo-runner register
      runner.service = {
        command = ["forgejo-runner" "daemon"];
        container_name = "forgejo-runner";
        depends_on = ["dind" "forgejo"];
        image = "code.forgejo.org/forgejo/runner:6"; # https://code.forgejo.org/forgejo/runner
        restart = "unless-stopped";
        user = "1001:1001";
        volumes = ["${config.custom.containers.directory}/forgejo/runner:/data"];

        environment = {
          DOCKER_HOST = "tcp://dind:2375";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [22]; # SSH

    systemd.tmpfiles.settings.forgejo = let
      owner = mode: {
        inherit mode;
        user = "1001";
        group = "1001";
      };
    in {
      "${config.custom.containers.directory}/forgejo/runner" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };
  };
}
