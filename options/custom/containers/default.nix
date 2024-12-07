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
    enable = mkOption {default = config.custom.full;};
    boot = mkOption {default = false;};
    directory = mkOption {default = "/containers";};
    docker = mkOption {default = true;};
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
        enableOnBoot = cfg.boot; # Socket activation
        storageDriver = "overlay2";
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

    environment.systemPackages = with pkgs;
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

    systemd.tmpfiles.settings."10-containers" = {
      "/containers" = {
        d = {
          mode = "0700";
          user = "root";
          group = "root";
        };
      };
    };

    users.users.${config.custom.username}.extraGroups = [
      (
        if cfg.docker
        then "docker"
        else "podman"
      )
    ];
  };
}
