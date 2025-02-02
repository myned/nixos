{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.caddy;
in {
  options.custom.services.caddy.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = "caddy";
        group = "caddy";
      };
    in {
      "${config.custom.profile}/caddy/Caddyfile" = secret "${config.custom.profile}/caddy/Caddyfile";
    };

    # https://caddyserver.com/
    # https://github.com/caddyserver/caddy
    services = {
      caddy = {
        enable = true;

        # TODO: Convert services to Tailscale subdomains when supported or use plugin when supported by nix
        # https://github.com/tailscale/tailscale/issues/7081
        # https://github.com/tailscale/caddy-tailscale
        # https://github.com/NixOS/nixpkgs/pull/317881
        configFile = config.age.secrets."${config.custom.profile}/caddy/Caddyfile".path;
      };
    };

    # Serve static files
    systemd.tmpfiles.settings."10-caddy" = {
      "/srv/static" = {
        d = {
          user = "caddy";
          group = "caddy";
        };

        #!! Recursive
        Z = {
          user = "caddy";
          group = "caddy";
        };
      };
    };

    # https://wiki.nixos.org/wiki/Firewall
    # https://github.com/coturn/coturn/blob/master/docker/coturn/README.md
    # https://element-hq.github.io/synapse/latest/turn-howto.html
    networking.firewall = {
      enable = true;

      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
        1935 # RTMP
        3478 # TURN
        5349 # TURN
      ];

      allowedUDPPorts = [
        3478 # TURN
        5349 # TURN
        8000 # WebRTC
        10080 # SRT
      ];

      allowedUDPPortRanges = [
        {
          # TURN
          from = 49152;
          to = 65535;
        }
      ];
    };
  };
}
