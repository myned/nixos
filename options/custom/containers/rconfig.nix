{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.rconfig;
in {
  options.custom.containers.rconfig = {
    enable = mkEnableOption "rconfig";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/rconfig/.env" = secret "${config.custom.profile}/rconfig/.env";
      "${config.custom.profile}/rconfig/db.env" = secret "${config.custom.profile}/rconfig/db.env";
    };

    #?? arion-rconfig pull
    environment.shellAliases.arion-rconfig = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.rconfig.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.rconfig.settings.services = {
      # https://v6docs.rconfig.com/
      # https://github.com/rconfig/rconfig6docker
      # https://github.com/rconfig/rconfig6docker/blob/main/docker-compose.yml
      rconfig.service = {
        container_name = "rconfig";
        depends_on = ["db" "vpn"];
        env_file = [config.age.secrets."${config.custom.profile}/rconfig/.env".path];
        image = "rconfig/rconfigv6:latest";
        network_mode = "service:vpn"; # 80/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/rconfig/data:/var/www/html/rconfig/storage"];
      };

      db.service = {
        container_name = "rconfig-db";
        env_file = [config.age.secrets."${config.custom.profile}/rconfig/db.env".path];
        image = "mariadb:11";
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/rconfig/db:/var/lib/mysql"];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "rconfig-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-rconfig";
        image = "ghcr.io/tailscale/tailscale:latest"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/rconfig/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };
  };
}
