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
      "${config.custom.hostname}/caddy/.env" = secret "${config.custom.hostname}/caddy/.env";
    };

    #?? arion-caddy pull
    environment.shellAliases.arion-caddy = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.caddy.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.caddy.settings.services = {
      # https://github.com/caddyserver/caddy
      # https://caddyserver.com/
      # https://caddyserver.com/docs/running#docker-compose
      caddy.service = {
        build.context = toString ./.;
        container_name = "caddy";
        env_file = [config.age.secrets."${config.custom.hostname}/caddy/.env".path];
        image = "localhost/caddy";
        network_mode = "host"; # 80/tcp 443/tcp/udp
        restart = "unless-stopped";
        user = "239:239";

        volumes = [
          "${config.custom.containers.directory}/caddy/config:/config"
          "${config.custom.containers.directory}/caddy/data:/data"
          "${config.custom.containers.directory}/caddy/etc:/etc/caddy:ro"
          "/srv:/srv:ro"
        ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];

      allowedUDPPorts = [
        443 # HTTP/3
      ];
    };

    # For remote access to /srv
    services.openssh.settings = optionalAttrs (isString cfg.public-key) {
      AllowUsers = ["srv"];
    };

    users = optionalAttrs (isString cfg.public-key) {
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

    systemd = {
      # HACK: Reload config instead of restarting service
      # https://nixos.org/manual/nixos/unstable/index.html#sec-unit-handling
      # https://discourse.nixos.org/t/reload-triggers-now-on-unstable-call-for-migration/17815
      services.arion-caddy = {
        # FIXME: Reload not triggered via file modification
        #// reloadTriggers = [./Caddyfile];
        reloadIfChanged = true; #!! Certain changes require service restart

        reload = ''
          arion --prebuilt-file "$ARION_PREBUILT" exec -- caddy \
            caddy reload --config /etc/caddy/Caddyfile
        '';
      };

      #?? arion-caddy run -- --rm --entrypoint='id caddy' caddy
      tmpfiles.settings.caddy = let
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
        # HACK: Copy files directly to trigger reloads
        # https://github.com/caddyserver/caddy/issues/5735#issuecomment-1675896585
        "${config.custom.containers.directory}/caddy/etc" = {
          C = owner "0500" // {argument = toString ./etc;}; # -r-x------
        };

        #!! Recursive
        "${config.custom.containers.directory}/caddy/etc/*" = {
          R = {}; # Replace existing files
        };

        #!! Recursive
        "/srv" = {
          d = owner "0700"; # -rwx------
          Z = owner "0700"; # -rwx------
        };
      };
    };
  };
}
