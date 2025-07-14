{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.kener;
in {
  options.custom.containers.kener = {
    enable = mkEnableOption "kener";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/kener/.env" = secret "${config.custom.hostname}/kener/.env";
      "${config.custom.hostname}/kener/db.env" = secret "${config.custom.hostname}/kener/db.env";
    };

    #?? arion-kener pull
    environment.shellAliases.arion-kener = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.kener.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.kener.settings.services = {
      # https://github.com/rajnandan1/kener
      # https://kener.ing/docs/deployment
      kener.service = {
        container_name = "kener";
        depends_on = ["db" "vpn"];
        env_file = [config.age.secrets."${config.custom.hostname}/kener/.env".path];
        image = "ghcr.io/rajnandan1/kener:latest"; # https://github.com/rajnandan1/kener/pkgs/container/kener
        network_mode = "service:vpn"; # 3000/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/kener/data:/app/uploads"];
      };

      # https://kener.ing/docs/database
      db.service = {
        container_name = "kener-db";
        env_file = [config.age.secrets."${config.custom.hostname}/kener/db.env".path];
        image = "postgres:17"; # https://hub.docker.com/_/postgres/tags
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/kener/db:/var/lib/postgresql/data"];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "kener-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-kener";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/kener/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };

    #?? arion-kener run -- --rm --entrypoint='id' kener
    systemd.tmpfiles.settings.kener = let
      owner = mode: {
        inherit mode;
        user = "1000"; # node
        group = "1000"; # node
      };
    in {
      "${config.custom.containers.directory}/kener/data" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };
  };
}
