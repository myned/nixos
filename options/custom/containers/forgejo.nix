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

    runner = mkOption {
      default = true;
      type = types.bool;
    };

    server = mkOption {
      default = false;
      type = types.bool;
    };
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

    virtualisation.arion.projects.forgejo.settings.services =
      optionalAttrs cfg.server {
        # https://codeberg.org/forgejo/forgejo
        # https://codeberg.org/forgejo/forgejo/src/branch/forgejo/Dockerfile.rootless
        # https://forgejo.org/docs/latest/admin/installation-docker/
        #?? arion-forgejo exec -- forgejo sudo -u git forgejo admin user create --username <username> --random-password --email <email> --admin
        forgejo.service = {
          container_name = "forgejo";
          depends_on = ["db" "vpn"];
          env_file = [config.age.secrets."${config.custom.profile}/forgejo/.env".path];
          image = "code.forgejo.org/forgejo/forgejo:11-rootless"; # https://code.forgejo.org/forgejo/-/packages/container/forgejo/11-rootless
          network_mode = "service:vpn"; # 22/tcp 3000/tcp
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/forgejo/data:/var/lib/gitea"];
        };

        db.service = {
          container_name = "forgejo-db";
          env_file = [config.age.secrets."${config.custom.profile}/forgejo/db.env".path];
          image = "postgres:15";
          network_mode = "service:vpn";
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/forgejo/db:/var/lib/postgresql/data"];
        };

        # https://tailscale.com/kb/1282/docker
        vpn.service = {
          container_name = "forgejo-vpn";
          devices = ["/dev/net/tun:/dev/net/tun"];
          env_file = [config.age.secrets."common/tailscale/container.env".path];
          hostname = "${config.custom.hostname}-forgejo";
          image = "ghcr.io/tailscale/tailscale:latest"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/forgejo/vpn:/var/lib/tailscale"];

          capabilities = {
            NET_ADMIN = true;
          };
        };
      }
      // optionalAttrs cfg.runner {
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

    #?? arion-forgejo run -- --rm --entrypoint=id forgejo
    systemd.tmpfiles.settings = {
      forgejo = let
        owner = mode: {
          inherit mode;
          user = "1000"; # git
          group = "1000"; # git
        };
      in
        mkIf cfg.server {
          "${config.custom.containers.directory}/forgejo/data" = {
            d = owner "0700"; # -rwx------
            z = owner "0700"; # -rwx------
          };
        };

      forgejo-runner = let
        owner = mode: {
          inherit mode;
          user = "1001";
          group = "1001";
        };
      in
        mkIf cfg.runner {
          "${config.custom.containers.directory}/forgejo/runner" = {
            d = owner "0700"; # -rwx------
            z = owner "0700"; # -rwx------
          };
        };
    };
  };
}
