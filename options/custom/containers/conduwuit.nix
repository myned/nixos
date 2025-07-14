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
      "${config.custom.hostname}/conduwuit/conduwuit.toml" = secret "${config.custom.hostname}/conduwuit/conduwuit.toml";
    };

    #?? arion-conduwuit pull
    environment.shellAliases.arion-conduwuit = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.conduwuit.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.conduwuit.settings.services = {
      # https://github.com/girlbossceo/conduwuit
      conduwuit.service = {
        container_name = "conduwuit";
        image = "ghcr.io/girlbossceo/conduwuit:v0.5.0-rc3-b6e9dc3d98704c56027219d3775336910a0136c6";
        ports = ["6167:6167/tcp"];
        restart = "unless-stopped";

        environment = {
          CONDUWUIT_CONFIG = "/etc/conduwuit/conduwuit.toml";
        };

        volumes = [
          "${config.custom.containers.directory}/conduwuit/db:/var/lib/conduwuit"
          "${config.age.secrets."${config.custom.hostname}/conduwuit/conduwuit.toml".path}:/etc/conduwuit/conduwuit.toml"
        ];
      };
    };
  };
}
