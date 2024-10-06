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
      "${config.custom.profile}/coturn/coturn.conf" = secret "${config.custom.profile}/coturn/coturn.conf";
    };

    #?? arion-coturn pull
    environment.shellAliases.arion-coturn = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.coturn.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.coturn = {
      serviceName = "coturn";

      settings.services = {
        # https://conduwuit.puppyirl.gay/turn.html
        coturn.service = {
          container_name = "coturn";
          image = "coturn/coturn:4.6";
          network_mode = "host";
          restart = "unless-stopped";

          volumes = [
            "${config.custom.containers.directory}/coturn/coturn.conf:/etc/coturn/turnserver.conf"
          ];
        };
      };
    };

    # TODO: Use nobody:nogroup instead when docker allows changing mount ownership
    # HACK: Copy with global read-only permissions in container directory which is assumed to be locked down
    # https://github.com/moby/moby/issues/2259
    systemd.tmpfiles.rules = [
      "C ${config.custom.containers.directory}/coturn/coturn.conf 0444 - - - ${
        config.age.secrets."${config.custom.profile}/coturn/coturn.conf".path
      }"
    ];
  };
}