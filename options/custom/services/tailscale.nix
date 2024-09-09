{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cat = "${pkgs.coreutils}/bin/cat";
  tailscale = "${config.services.tailscale.package}/bin/tailscale";

  cfg = config.custom.services.tailscale;
in
{
  # TODO: Enact recommendations
  # https://tailscale.com/kb/1320/performance-best-practices
  # https://github.com/tailscale/tailscale
  #!! Configuration is imperative
  #?? sudo tailscale up --ssh --advertise-exit-node --accept-routes --operator=$USER --reset --qr
  options.custom.services.tailscale = {
    enable = mkOption { default = false; };
    cert = mkOption { default = false; };
  };

  # TODO: Use caddy plugin for provisioning when supported by NixOS
  # https://github.com/NixOS/nixpkgs/pull/317881
  # https://github.com/tailscale/caddy-tailscale
  config = mkIf cfg.enable {
    age.secrets =
      let
        secret = filename: {
          file = "${inputs.self}/secrets/${filename}";
        };
      in
      {
        "common/tailscale/tailnet" = secret "common/tailscale/tailnet";
      };

    services.tailscale = {
      enable = true;
      #// permitCertUid = mkIf cfg.cert "caddy"; # Allow caddy to fetch TLS certificates
      useRoutingFeatures = "both"; # Enable server/client exit nodes
    };

    # Provision Tailscale certificates in the background per machine
    systemd =
      let
        hostname = config.custom.hostname;
      in
      mkIf cfg.cert {
        #!! Needs to be run on the machine
        # tailscale cert always writes to /var/lib/tailscale/certs/ regardless of flags
        services."tailscale-cert-${hostname}".script = concatStringsSep " " [
          "${tailscale} cert"
          "--cert-file -"
          "--key-file -"
          "${hostname}.\"$(${cat} ${config.age.secrets."common/tailscale/tailnet".path})\""
          "> /dev/null"
        ];

        timers."tailscale-cert-${hostname}" = {
          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnCalendar = "daily";
            Persistent = true; # Retry if previous timer missed
          };
        };
      };
  };
}
