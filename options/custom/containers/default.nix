{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers;
in {
  options.custom.containers = {
    enable = mkOption {default = false;};
    boot = mkOption {default = false;};
    directory = mkOption {default = "/containers";};
    docker = mkOption {default = true;};
    user = mkOption {default = "root";};
  };

  config = mkIf cfg.enable {
    virtualisation = {
      # https://github.com/hercules-ci/arion
      # https://docs.hercules-ci.com/arion/options
      # https://docs.hercules-ci.com/arion/deployment#_nixos_module
      arion.backend =
        if cfg.docker
        then "docker"
        else "podman-socket";

      # https://wiki.nixos.org/wiki/NixOS_Containers
      oci-containers.backend =
        if cfg.docker
        then "docker"
        else "podman";

      # https://github.com/containers/common/blob/main/docs/containers.conf.5.md
      containers = {
        enable = true;
        containersConf.settings.engine.compose_warning_logs = !cfg.docker;
      };

      # https://www.docker.com
      # https://wiki.nixos.org/wiki/Docker
      docker = mkIf cfg.docker {
        enable = true;
        autoPrune.enable = true;
        enableOnBoot = cfg.boot; # Socket activation
        storageDriver = "overlay2";

        # https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file
        daemon.settings = {
          # https://docs.docker.com/engine/daemon/ipv6/
          # https://docs.docker.com/engine/network/drivers/bridge/#use-ipv6-with-the-default-bridge-network
          # https://wiki.archlinux.org/title/Docker#IPv6
          ipv6 = true;
          fixed-cidr-v6 = "fd00::/80";

          #!! userland-proxy has many implications, do not touch for now
          # https://github.com/moby/moby/issues/15086
          # https://github.com/moby/moby/issues/14856
          # https://github.com/docker/docs/issues/17312
          #// userland-proxy = false;

          # https://docs.docker.com/reference/cli/dockerd/#default-network-options
          default-network-opts = {
            # https://github.com/nextcloud/all-in-one/blob/main/docker-ipv6-support.md
            # https://rexum.space/p/enabling-ipv6-support-for-docker-and-docker-compose/
            bridge = {
              "com.docker.network.enable_ipv6" = "true"; # Enable for default compose bridge
            };
          };
        };
      };

      # https://github.com/containers/podman
      # https://wiki.nixos.org/wiki/Podman
      podman = mkIf (!cfg.docker) {
        enable = true;
        dockerCompat = true; # Drop-in for docker command
        dockerSocket.enable = true; # Docker API
        defaultNetwork.settings.dns_enabled = true; # Compose container shortnames

        autoPrune = {
          enable = true;
          flags = [
            "--all"
            "--volumes"
          ];
        };
      };
    };

    environment = {
      systemPackages = with pkgs;
        [
          # https://github.com/hercules-ci/arion/issues/210
          #?? arion-CONTAINER
          arion

          # https://github.com/aksiksi/compose2nix
          # Convert docker-compose.yml to NixOS oci-containers
          #?? compose2nix
          #// inputs.compose2nix.packages.${system}.default
        ]
        ++ optionals (!cfg.docker) [
          podman-compose
          podman-tui
        ];

      shellAliases = {
        # https://github.com/aksiksi/compose2nix?tab=readme-ov-file#usage
        # https://github.com/aksiksi/compose2nix?tab=readme-ov-file#agenix
        compose2nix = concatStringsSep " " [
          "compose2nix"
          "--inputs compose.yaml"
          "--output compose.nix"
          "--root_path /containers"
          "--auto_format"
          "--check_systemd_mounts"
          "--env_files_only"
          "--ignore_missing_env_files"
          "--include_env_files"
          #?? --env_files /run/agenix/containers/*/.env
        ];
      };
    };

    systemd.tmpfiles.settings.containers = let
      owner = mode: {
        inherit mode;
        user = cfg.user;
        group = "root";
      };
    in {
      ${cfg.directory} = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };

    users.users.${cfg.user}.extraGroups = [
      (
        if cfg.docker
        then "docker"
        else "podman"
      )
    ];

    age.secrets = listToAttrs (map (name: {
        inherit name;
        value = {file = "${inputs.self}/secrets/${name}";};
      })
      [
        "common/gluetun/container.env"
        "common/tailscale/container.env"
      ]);
  };
}
