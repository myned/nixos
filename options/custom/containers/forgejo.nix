{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.forgejo;
in {
  options.custom.containers.forgejo.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/forgejo/.env" = secret "${config.custom.profile}/forgejo/.env";
      "${config.custom.profile}/forgejo/db.env" = secret "${config.custom.profile}/forgejo/db.env";
    };

    #?? arion-forgejo pull
    environment.shellAliases.arion-forgejo = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.forgejo.settings.out.dockerComposeYaml}";

    networking.firewall.allowedTCPPorts = [22]; # SSH

    virtualisation.arion.projects.forgejo.settings.services = {
      # https://codeberg.org/forgejo/forgejo
      # https://forgejo.org/docs/latest/admin/
      #?? docker exec -it forgejo bash
      #?? sudo -u git forgejo admin user create --username USERNAME --random-password --email EMAIL --admin
      forgejo.service = {
        container_name = "forgejo";
        depends_on = ["db"];
        env_file = [config.age.secrets."${config.custom.profile}/forgejo/.env".path];
        image = "codeberg.org/forgejo/forgejo:8";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/forgejo/data:/data"];

        ports = [
          "127.0.0.1:3333:3000"
          "22:2222"
        ];
      };

      db.service = {
        container_name = "forgejo-db";
        env_file = [config.age.secrets."${config.custom.profile}/forgejo/db.env".path];
        image = "postgres:15";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/forgejo/db:/var/lib/postgresql/data"];
      };
    };
  };
}
