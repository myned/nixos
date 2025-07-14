{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.coturn;
in {
  options.custom.containers.coturn.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/coturn/coturn.conf" = secret "${config.custom.hostname}/coturn/coturn.conf";
    };

    #?? arion-coturn pull
    environment.shellAliases.arion-coturn = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.coturn.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.coturn.settings.services = {
      # https://conduwuit.puppyirl.gay/turn.html
      coturn.service = {
        container_name = "coturn";
        image = "coturn/coturn:4"; # https://hub.docker.com/r/coturn/coturn/tags
        network_mode = "host";
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/coturn/coturn.conf:/etc/coturn/turnserver.conf"
        ];
      };
    };

    # TODO: Use nobody:nogroup instead when docker allows changing mount ownership
    # HACK: Copy with global read-only permissions in container directory which is assumed to be locked down
    # https://github.com/moby/moby/issues/2259
    systemd.tmpfiles.settings.coturn = {
      "${config.custom.containers.directory}/coturn/coturn.conf" = {
        C = {
          mode = "0444";
          argument = "${config.age.secrets."${config.custom.hostname}/coturn/coturn.conf".path}";
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        3478 # TURN
        5349 # TURN
      ];

      allowedUDPPorts = [
        3478 # TURN
        5349 # TURN
      ];

      allowedUDPPortRanges = [
        {
          # TURN
          from = 49152;
          to = 65535;
        }
      ];
    };
  };
}
