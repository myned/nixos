{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.containers.headscale;
in {
  options.custom.settings.containers.headscale.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/headscale/.env" = secret "${config.custom.profile}/headscale/.env";
    };

    #?? arion-headscale pull
    environment.shellAliases.arion-headscale = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.headscale.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.headscale = {
      serviceName = "headscale";

      settings.services = {
        # https://headscale.net/
        # https://github.com/juanfont/headscale
        # BUG: Does not support generic DoH/DoT
        # https://github.com/juanfont/headscale/issues/1312
        headscale.service = {
          command = "serve";
          container_name = "headscale";
          env_file = [config.age.secrets."${config.custom.profile}/headscale/.env".path];
          image = "headscale/headscale:v0.23.0-beta.4";
          restart = "unless-stopped";

          ports = [
            "9999:9999"
            "9090:9090"
          ];

          volumes = [
            "${config.custom.settings.containers.directory}/headscale/config:/etc/headscale"
            "${config.custom.settings.containers.directory}/headscale/data:/var/lib/headscale"

            # Minimum config.yaml
            # https://github.com/juanfont/headscale/blob/main/config-example.yaml
            # https://github.com/juanfont/headscale/blob/main/integration/hsic/config.go
            "${pkgs.writeText "config.yaml" ''
              noise:
                private_key_path: /var/lib/headscale/noise_private.key
            ''}:/etc/headscale/config.yaml"
          ];
        };
      };
    };
  };
}
