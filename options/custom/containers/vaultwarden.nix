{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.vaultwarden;
in {
  options.custom.containers.vaultwarden = {
    enable = mkOption {default = false;};
    menu = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/vaultwarden/.env" = secret "${config.custom.profile}/vaultwarden/.env";
    };

    #?? arion-vaultwarden pull
    environment.shellAliases.arion-vaultwarden = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.vaultwarden.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.vaultwarden.settings.services = {
      # https://github.com/dani-garcia/vaultwarden
      # https://github.com/dani-garcia/vaultwarden/wiki
      vaultwarden.service = {
        container_name = "vaultwarden";
        env_file = [config.age.secrets."${config.custom.profile}/vaultwarden/.env".path];
        image = "vaultwarden/server:1.33.2"; # https://hub.docker.com/r/vaultwarden/server/tags
        ports = ["8088:80/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/vaultwarden/data:/data"];
      };
    };
  };
}
