{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.caddy;
in {
  options.custom.services.caddy = {
    enable = mkEnableOption "caddy";

    redirectHttp = mkOption {
      description = "Whether to permanently redirect HTTP to HTTPS";
      default = true;
      example = false;
      type = types.bool;
    };

    layer4Config = mkOption {
      description = "Config for the caddy-l4 plugin";
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

    openFirewall = mkOption {
      description = "Whether to allow ports 80/tcp/udp and 443/tcp/udp through the firewall";
      default = true;
      example = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Caddy
    # https://caddyserver.com/
    # https://github.com/caddyserver/caddy
    services = {
      caddy = {
        enable = true;

        # https://wiki.nixos.org/wiki/Caddy#Plug-ins
        #?? Copy hash/tag from failed build
        package = pkgs.caddy.withPlugins {
          hash = "sha256-ujjlyTBJqrEoSFDxb14rWh7VDCaSmhqnC+/BqYgbMgY=";

          #?? <repo>@<tag>
          plugins = [
            "github.com/mholt/caddy-l4@v0.0.0-20251209130418-1a3490ef786a" # https://github.com/mholt/caddy-l4
            #// "github.com/tailscale/caddy-tailscale@f070d146dd6169aa29376ee9ac5a3e16763f9cb2" # https://github.com/tailscale/caddy-tailscale
            #// "github.com/caddy-dns/cloudflare@v0.2.2" # https://github.com/caddy-dns/cloudflare
          ];
        };

        globalConfig = ''
          auto_https disable_redirects

          layer4 {
            ${cfg.layer4Config}
          }
        '';

        virtualHosts = {
          "http://" = mkIf cfg.redirectHttp {
            extraConfig = "redir https://{host}{uri} 308";
          };
        };
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];

      allowedUDPPorts = [
        80 # HTTP
        443 # HTTPS
      ];
    };
  };
}
