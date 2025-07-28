{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.oryx;
in {
  options.custom.containers.oryx = {
    enable = mkEnableOption "oryx";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/oryx/.env" = secret "${config.custom.hostname}/oryx/.env";
    };

    #?? arion-oryx pull
    environment.shellAliases.arion-oryx = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.oryx.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.oryx.settings.services = {
      oryx.service = {
        container_name = "oryx";
        env_file = [config.age.secrets."${config.custom.hostname}/oryx/.env".path];
        image = "ossrs/oryx:5.15.20"; # https://hub.docker.com/r/ossrs/oryx/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/oryx/data:/data"];

        ports = [
          "2022:2022/tcp" # HTTP
          "${config.custom.services.tailscale.ipv4}:1935:1935/tcp" # RTMP
          "${config.custom.services.tailscale.ipv4}:8000:8000/udp" # WebRTC
          "${config.custom.services.tailscale.ipv4}:10080:10080/udp" # SRT
        ];
      };
    };
  };
}
