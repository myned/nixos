{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.kasm;
in {
  options.custom.containers.kasm = {
    enable = mkEnableOption "kasm";
  };

  config = mkIf cfg.enable {
    #?? arion-kasm pull
    environment.shellAliases.arion-kasm = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.kasm.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.kasm.settings.services = {
      # https://kasmweb.com/
      # https://kasmweb.com/docs/latest/index.html
      # https://github.com/linuxserver/docker-kasm
      kasm.service = {
        container_name = "kasm";
        image = "ghcr.io/linuxserver/kasm:1.17.0"; # https://github.com/linuxserver/docker-kasm/pkgs/container/kasm
        privileged = true;
        restart = "unless-stopped";

        ports = [
          "3443:3000/tcp" # Admin panel
          "4443:4443/tcp" # Main interface
        ];

        volumes = [
          "${config.custom.containers.directory}/kasm/data:/opt"
          "${config.custom.containers.directory}/kasm/profiles:/profiles"

          # Gamepad support
          "/dev/input:/dev/input"
          "/run/udev/data:/run/udev/data"
        ];

        environment = {
          KASM_PORT = "4443";
        };
      };
    };
  };
}
