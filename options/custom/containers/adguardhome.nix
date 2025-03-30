{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.adguardhome;
in {
  options.custom.containers.adguardhome = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    #?? arion-adguardhome pull
    environment.shellAliases.arion-adguardhome = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.adguardhome.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.adguardhome.settings.services = {
      # https://github.com/AdguardTeam/AdGuardHome
      # https://adguard-dns.io/kb/adguard-home/overview/
      #?? ls /var/lib/caddy/.local/share/caddy/certificates/*
      adguardhome.service = {
        container_name = "adguardhome";
        image = "adguard/adguardhome:v0.107.59";

        ports = [
          "53:53/tcp" # DNS
          "53:53/udp" # DNS
          "853:853/tcp" # DNS-over-TLS
          "853:853/udp" # DNS-over-QUIC
          "3003:80/tcp" # Admin panel
          "8443:443/tcp" # DNS-over-HTTPS
        ];

        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/adguardhome/config:/opt/adguardhome/conf"
          "${config.custom.containers.directory}/adguardhome/data:/opt/adguardhome/data"
        ];
      };
    };

    # https://github.com/AdguardTeam/AdGuardHome/wiki/Encryption
    networking.firewall = {
      allowedTCPPorts = [
        #// 53 # DNS
        #// 853 # DNS-over-TLS
      ];

      allowedUDPPorts = [
        #// 53 # DNS
        #// 853 # DNS-over-QUIC
      ];
    };

    # https://adguard-dns.io/kb/adguard-home/faq/#bindinuse
    services.resolved.extraConfig = ''
      DNSStubListener=false
    '';
  };
}
