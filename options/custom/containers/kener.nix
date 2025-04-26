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
      "${config.custom.profile}/kener/.env" = secret "${config.custom.profile}/kener/.env";
      "${config.custom.profile}/kener/db.env" = secret "${config.custom.profile}/kener/db.env";
    };

    #?? arion-kener pull
    environment.shellAliases.arion-kener = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.kener.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.kener.settings.services = {
      # https://github.com/rajnandan1/kener
      # https://kener.ing/docs/deployment
      kener.service = {
        container_name = "kener";
        depends_on = ["db"];
        dns = ["100.100.100.100"]; # Tailscale resolver
        env_file = [config.age.secrets."${config.custom.profile}/kener/.env".path];
        image = "ghcr.io/rajnandan1/kener:3"; # https://github.com/rajnandan1/kener/pkgs/container/kener
        ports = ["127.0.0.1:3030:3000/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/kener/data:/app/uploads"];
      };

      # https://kener.ing/docs/database
      db.service = {
        container_name = "kener-db";
        env_file = [config.age.secrets."${config.custom.profile}/kener/db.env".path];
        image = "postgres:17"; # https://hub.docker.com/_/postgres/tags
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/kener/db:/var/lib/postgresql/data"];
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
