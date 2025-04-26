{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.caddy;
in {
  options.custom.containers.caddy = {
    enable = mkEnableOption "caddy";

    public-key = mkOption {
      default = null;
      type = with types; nullOr str;
    };
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

        volumes = [
          "${config.custom.containers.directory}/caddy/config:/config"
          "${config.custom.containers.directory}/caddy/data:/data"
          "${./Caddyfile}:/etc/caddy/Caddyfile:ro"
          "/srv:/srv:ro"
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];
    };

    # For write access to /srv
    services.openssh.settings = mkIf (isString cfg.public-key) {
      AllowUsers = ["srv"];
    };

    users = mkIf (isString cfg.public-key) {
      users.srv = {
        uid = 239;
        group = "srv";
        shell = pkgs.bash;

        #?? ssh-keygen -f ./srv -N '' -C ''
        openssh.authorizedKeys.keys = [cfg.public-key];
      };

      groups.srv = {
        gid = 239;
      };
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

      #!! Recursive
      "/srv" = {
        d = owner "0700"; # -rwx------
        Z = owner "0700"; # -rwx------
      };
    };
  };
}
