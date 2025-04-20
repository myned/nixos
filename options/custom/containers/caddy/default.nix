{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.caddy;
in {
  options.custom.containers.caddy = {
    enable = mkEnableOption "caddy";
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/caddy/.env" = secret "${config.custom.profile}/caddy/.env";
    };

    #?? arion-caddy pull
    environment.shellAliases.arion-caddy = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.caddy.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.caddy.settings.services = {
      # https://github.com/caddyserver/caddy
      # https://caddyserver.com/
      # https://caddyserver.com/docs/running#docker-compose
      caddy.service = {
        build.context = "${./.}";
        container_name = "caddy";
        env_file = [config.age.secrets."${config.custom.profile}/caddy/.env".path];
        image = "localhost/caddy";
        network_mode = "host"; # 80/tcp 443/tcp/udp
        restart = "unless-stopped";

        volumes =
          [
            "${config.custom.containers.directory}/caddy/config:/config"
            "${config.custom.containers.directory}/caddy/data:/data"
            "${config.custom.containers.directory}/caddy/static:/static:ro"
            "${./Caddyfile}:/etc/caddy/Caddyfile:ro"
            "${./site}:/srv:ro"
          ]
          ++ optionals config.custom.containers.synapse.enable [
            "/run/synapse/synapse.sock:/run/synapse/synapse.sock:ro"
          ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];
    };

    #?? arion-caddy run -- --rm --entrypoint='id caddy' caddy
    systemd.tmpfiles.settings.caddy = let
      owner = mode: {
        inherit mode;
        user = "239"; # caddy
        group = "239"; # caddy
      };
    in {
      "${config.custom.containers.directory}/caddy/config" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/caddy/data" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };
  };
}
