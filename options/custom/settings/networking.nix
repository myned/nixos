{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.networking;
in {
  options.custom.settings.networking = {
    enable = mkOption {default = false;};
    dns = mkOption {default = config.custom.default;};
    ipv4 = mkOption {default = null;};
    ipv6 = mkOption {default = null;};
    networkd = mkOption {default = !cfg.networkmanager;};
    networkmanager = mkOption {default = config.custom.minimal;};
    static = mkOption {default = false;}; # Falls back to DHCP/RA
    wifi = mkOption {default = config.custom.minimal;};

    interface = mkOption {
      default = [
        "en*"
        "eth*"
      ];
    };
  };

  config = mkIf cfg.enable {
    #!! Imperative networking
    #?? nmtui or nmcli
    # https://wiki.nixos.org/wiki/Networking
    networking = {
      hostName = config.custom.hostname;
      useNetworkd = cfg.networkd;
      wireless.iwd.enable = cfg.wifi;

      networkmanager = mkIf cfg.networkmanager {
        enable = true;
        wifi.backend = mkIf cfg.wifi "iwd";
      };
    };

    users.users.${config.custom.username}.extraGroups = mkIf cfg.networkmanager ["networkmanager"];

    # Declarative networking
    #?? networkctl
    # https://wiki.nixos.org/wiki/Systemd/networkd
    systemd.network = mkIf (!cfg.networkmanager) {
      enable = true;

      networks."10-static" = mkIf cfg.static {
        linkConfig.RequiredForOnline = "routable";
        matchConfig.Name = cfg.interface;

        networkConfig = {
          DHCP = mkIf (isNull cfg.ipv4) "ipv4";
          IPv6AcceptRA = isNull cfg.ipv6;
        };

        address =
          optionals (!isNull cfg.ipv4) [
            cfg.ipv4
          ]
          ++ optionals (!isNull cfg.ipv6) [
            cfg.ipv6
          ];
      };
    };

    # DNS resolver
    # https://wiki.nixos.org/wiki/Systemd-resolved
    services.resolved = mkIf cfg.dns {
      enable = true;
      dnsovertls = "opportunistic"; # Fallback only
      #// domains = [ "~." ]; # All interfaces

      # Multicast DNS causes single name resolution to hang and prevents libvirt NSS from functioning
      # https://github.com/NixOS/nixpkgs/issues/322022
      extraConfig = "MulticastDNS=false"; # mDNS
      llmnr = "false";

      # https://controld.com/free-dns
      #?? host verify.controld.com
      fallbackDns = mkIf cfg.dns [
        "76.76.2.22#p0.freedns.controld.com"
        "76.76.10.22#p0.freedns.controld.com"
        "2606:1a40::22#p0.freedns.controld.com"
        "2606:1a40:1::22#p0.freedns.controld.com"
      ];
    };

    #!! Override nsswitch.conf resolution order
    #!! nss-resolve blocks some modules after [!UNAVAIL=return]
    # https://wiki.archlinux.org/title/Systemd-resolved#systemd-resolved_not_searching_the_local_domain
    # https://github.com/NixOS/nixpkgs/issues/132646
    # Default: mymachines resolve [!UNAVAIL=return] files myhostname libvirt_guest libvirt dns
    # TODO: Remove elements from final list instead of forcing
    system.nssDatabases.hosts = mkIf config.custom.full (mkForce [
      "files"
      "myhostname"
      "mymachines"
      "libvirt_guest"
      "libvirt"
      #// "wins"
      "resolve"
      "dns"
    ]);

    # Wireless regulatory domain
    # https://github.com/NixOS/nixpkgs/issues/25378
    boot.extraModprobeConfig = mkIf cfg.wifi ''
      options cfg80211 ieee80211_regdom="US"
    '';
  };
}
