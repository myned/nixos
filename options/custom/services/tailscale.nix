{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.tailscale;

  tailscale = getExe config.services.tailscale.package;
in {
  # TODO: Enact recommendations
  # https://tailscale.com/kb/1320/performance-best-practices
  # https://github.com/tailscale/tailscale
  #!! Configuration is imperative
  #?? sudo tailscale up --ssh --advertise-exit-node --accept-routes --operator=$USER --reset --qr
  options.custom.services.tailscale = {
    enable = mkOption {default = false;};
    cert = mkOption {default = false;};
    ip = mkOption {default = "";};
    firewall = mkOption {default = true;};
    tailnet = mkOption {default = "fenrir-musical.ts.net";};
    tray = mkOption {default = false;};
  };

  # TODO: Use caddy plugin for provisioning when supported by NixOS
  # https://github.com/NixOS/nixpkgs/pull/317881
  # https://github.com/tailscale/caddy-tailscale
  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = cfg.firewall; # 41641/udp
      permitCertUid = mkIf config.custom.services.caddy.enable "caddy"; # Allow caddy to fetch TLS certificates
      useRoutingFeatures = "both"; # Enable server/client exit nodes
    };

    networking.firewall.interfaces.${config.services.tailscale.interfaceName} = let
      all-ports = {
        from = 0;
        to = 65535;
      };
    in
      mkIf cfg.firewall {
        allowedTCPPortRanges = [all-ports];
        allowedUDPPortRanges = [all-ports];
      };

    # Provision Tailscale certificates in the background per machine
    systemd = mkIf cfg.cert {
      #!! Needs to be run on the machine
      # tailscale cert always writes to /var/lib/tailscale/certs/ regardless of flags
      services."tailscale-cert-${config.custom.hostname}".script = concatStringsSep " " [
        "${tailscale} cert"
        "--cert-file -"
        "--key-file -"
        "${config.custom.hostname}.${cfg.tailnet}"
        "> /dev/null"
      ];

      timers."tailscale-cert-${config.custom.hostname}" = {
        wantedBy = ["timers.target"];

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true; # Retry if previous timer missed
        };
      };
    };

    home-manager.sharedModules = [
      {
        # https://github.com/DeedleFake/trayscale
        services.trayscale.enable = cfg.tray;
      }
    ];
  };
}
