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

        # BUG: DNS-over-TLS not currently functional, reattempt when fixed or PROXY protocol supported
        # https://github.com/mholt/caddy-l4/issues/276
        # https://github.com/AdguardTeam/AdGuardHome/issues/2798
        # TODO: Use stable package when available with plugins
        # https://github.com/NixOS/nixpkgs/pull/358586
        package = pkgs.unstable.caddy.withPlugins {
          #?? Copy from failed build
          hash = "sha256-W09nFfBKd+9QEuzV3RYLeNy2CTry1Tz3Vg1U2JPNPPc=";

          #?? REPO@TAG
          plugins = [
            # https://github.com/caddy-dns/cloudflare
            "github.com/caddy-dns/cloudflare@v0.0.0-20240703190432-89f16b99c18e"

            # https://github.com/mholt/caddy-l4
            #// "github.com/mholt/caddy-l4@v0.0.0-20250124234235-87e3e5e2c7f9"

            # https://github.com/tailscale/caddy-tailscale
            #// "github.com/tailscale/caddy-tailscale@v0.0.0-20250207004440-fd3f49d73216"
          ];
        };

        # TODO: Convert services to Tailscale subdomains when supported or use plugin when supported by nix
        # https://github.com/tailscale/tailscale/issues/7081
        # https://github.com/tailscale/caddy-tailscale
        # https://github.com/NixOS/nixpkgs/pull/317881
        configFile = config.age.secrets."${config.custom.profile}/caddy/Caddyfile".path;
      };
    };

    # Serve static files
    systemd.tmpfiles.settings.caddy = {
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

    networking.firewall = {
      allowedTCPPorts = [
        80 # HTTP
        443 # HTTPS
      ];
    };
  };
}
