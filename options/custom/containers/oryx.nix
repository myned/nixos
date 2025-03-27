{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.oryx;
in {
  options.custom.containers.oryx.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/oryx/.env" = secret "${config.custom.profile}/oryx/.env";
    };

    #?? arion-oryx pull
    environment.shellAliases.arion-oryx = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.oryx.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.oryx.settings.services = {
      oryx.service = {
        container_name = "oryx";
        env_file = [config.age.secrets."${config.custom.profile}/oryx/.env".path];
        image = "ossrs/oryx:5";

        ports = [
          "127.0.0.1:2022:2022/tcp" # HTTP
          "1935:1935/tcp" # RTMP
          "8000:8000/udp" # WebRTC
          "10080:10080/udp" # SRT
        ];

        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/oryx/data:/data"];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        #// 1935 # RTMP
      ];

      allowedUDPPorts = [
        8000 # WebRTC
        10080 # SRT
      ];
    };
  };
}
