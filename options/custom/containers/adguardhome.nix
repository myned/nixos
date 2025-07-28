{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.adguardhome;
in {
  options.custom.containers.adguardhome = {
    enable = mkEnableOption "adguardhome";
  };

  config = mkIf cfg.enable {
    #?? arion-adguardhome pull
    environment.shellAliases.arion-adguardhome = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.adguardhome.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.adguardhome.settings.services = {
      # https://github.com/AdguardTeam/AdGuardHome
      # https://adguard-dns.io/kb/adguard-home/overview/
      #?? ls /containers/caddy/data/caddy/certificates/*
      adguardhome.service = {
        container_name = "adguardhome";
        depends_on = ["vpn"];
        image = "adguard/adguardhome:v0.107.63"; # https://hub.docker.com/r/adguard/adguardhome/tags
        network_mode = "service:vpn"; # 80/tcp
        restart = "unless-stopped";

        volumes = [
          # https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
          "${config.custom.containers.directory}/adguardhome/config:/opt/adguardhome/conf"
          "${config.custom.containers.directory}/adguardhome/data:/opt/adguardhome/data"
        ];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "adguardhome-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-adguardhome";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/adguardhome/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };

        ports = [
          #// "53:53/tcp" # DNS
          #// "53:53/udp" # DNS
          "853:853/tcp" # DNS-over-TLS
          "853:853/udp" # DNS-over-QUIC
          #// "3003:80/tcp" # Admin panel
          #// "8443:443/tcp" # DNS-over-HTTPS
        ];
      };
    };

    # https://github.com/AdguardTeam/AdGuardHome/wiki/Encryption
    networking.firewall = {
      allowedTCPPorts = [853]; # DNS-over-TLS
      allowedUDPPorts = [853]; # DNS-over-QUIC
    };

    # https://adguard-dns.io/kb/adguard-home/faq/#bindinuse
    # services.resolved.extraConfig = ''
    #   DNSStubListener=false
    # '';
  };
}
