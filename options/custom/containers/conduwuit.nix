{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.conduwuit;
in {
  options.custom.containers.conduwuit.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/conduwuit/conduwuit.toml" = secret "${config.custom.profile}/conduwuit/conduwuit.toml";
    };

    #?? arion-conduwuit pull
    environment.shellAliases.arion-conduwuit = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.conduwuit.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.conduwuit.settings.services = {
      # https://github.com/girlbossceo/conduwuit
      conduwuit.service = {
        container_name = "conduwuit";
        image = "girlbossceo/conduwuit:v0.5.0-rc3";
        ports = ["127.0.0.1:6167:6167/tcp"];
        restart = "unless-stopped";

        environment = {
          CONDUWUIT_CONFIG = "/etc/conduwuit/conduwuit.toml";
        };

        volumes = [
          "${config.custom.containers.directory}/conduwuit/db:/var/lib/conduwuit"
          "${config.age.secrets."${config.custom.profile}/conduwuit/conduwuit.toml".path}:/etc/conduwuit/conduwuit.toml"
        ];
      };
    };
  };
}
