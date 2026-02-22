{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.caddy;
in {
  options.custom.services.caddy = {
    enable = mkEnableOption "caddy";

    openFirewall = mkOption {
      description = "Whether to open the firewall for ports 80/tcp and 443/tcp/udp";
      default = true;
      example = false;
      type = types.bool;
    };

    importEnvironment = mkOption {
      description = "Whether to import the agenix secrets file in the Caddy environment";
      default = false;
      example = true;
      type = types.bool;
    };

    srvKey = mkOption {
      description = "Public key of the `srv` user for remote readwrite access to /srv";
      default = null;
      example = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhvdtKO/8RmCE7XumGfezAHojW2cMXMED3exmFslHch";
      type = with types; nullOr str;
    };

    globalConfig = mkOption {
      description = "Config to append in the global section of the generated Caddyfile";
      default = "";
      example = ''
        ech ech.example.com
      '';
      type = types.str;
    };

    extraConfig = mkOption {
      description = "Config to append in the generated Caddyfile";
      default = "";
      example = ''
        reverse_proxy localhost:80
      '';
      type = types.str;
    };

    layer4Config = mkOption {
      description = "Config to append for the caddy-l4 plugin in the global section of the generated Caddyfile";
      default = "";
      example = ''
        :443 {
          route {
            proxy localhost:443
          }
        }
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Caddy
    # https://caddyserver.com/
    # https://github.com/caddyserver/caddy
    services = {
      caddy = {
        enable = true;
        # TODO: Uncomment when supported in stable
        #// openFirewall = true;
        email = "admin@${config.custom.domain}";
        extraConfig = cfg.extraConfig;
        environmentFile = mkIf cfg.importEnvironment config.age.secrets."${config.custom.hostname}/caddy/.env".path;

        # https://wiki.nixos.org/wiki/Caddy#Plug-ins
        #?? Copy hash/tag from failed build
        package = pkgs.caddy.withPlugins {
          hash = "sha256-3vC+tM51Q41H62MunJIGG1DUotIHj5/lYh3WyUtgppA=";

          #?? <repo>@<tag>
          plugins = [
            "github.com/caddy-dns/cloudflare@v0.2.2" # https://github.com/caddy-dns/cloudflare
            "github.com/mholt/caddy-l4@v0.0.0-20251209130418-1a3490ef786a" # https://github.com/mholt/caddy-l4
            #// "github.com/tailscale/caddy-tailscale@f070d146dd6169aa29376ee9ac5a3e16763f9cb2" # https://github.com/tailscale/caddy-tailscale
          ];
        };

        # https://letsencrypt.org/getting-started/
        # https://letsencrypt.org/docs/staging-environment/
        acmeCA = "https://acme-v02.api.letsencrypt.org/directory"; #!! Production
        #// acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory"; #!! Staging

        # # https://caddyserver.com/docs/logging
        logFormat = ''
          format console
          level INFO
        '';

        globalConfig = ''
          layer4 {
            ${cfg.layer4Config}
          }

          ${cfg.globalConfig}
        '';
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];

      allowedUDPPorts = [
        443 # HTTP/3
      ];
    };

    # For remote rw access to /srv
    services.openssh.settings = mkIf (!isNull cfg.srvKey) {
      AllowUsers = ["srv"];
    };

    users.users.srv = mkIf (!isNull cfg.srvKey) {
      isNormalUser = true;
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [cfg.srvKey]; #?? ssh-keygen -f ./srv -N '' -C ''
    };

    systemd.tmpfiles.settings.srv = let
      owner = mode: {
        inherit mode;
        user = "srv";
        group = "caddy";
      };
    in
      mkIf (!isNull cfg.srvKey) {
        "/srv" = {
          d = owner "0750"; # -rwxr-x---
          Z = owner "0750"; # -rwxr-x---
        };
      };

    age.secrets = mkIf cfg.importEnvironment (listToAttrs (map (name: {
        inherit name;
        value = {file = "${inputs.self}/secrets/${name}";};
      })
      [
        "${config.custom.hostname}/caddy/.env"
      ]));
  };
}
