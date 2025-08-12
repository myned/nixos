{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.networking;

  cut = getExe' pkgs.coreutils "cut";
  ethtool = getExe pkgs.ethtool;
  ip = getExe' pkgs.iproute2 "ip";
in {
  options.custom.settings.networking = {
    enable = mkEnableOption "networking";

    dns = mkOption {
      default = config.custom.default;
      type = types.bool;
    };

    dnsmasq = mkOption {
      default = config.custom.full;
      type = types.bool;
    };

    firewall = mkOption {
      default = config.custom.default;
      type = types.bool;
    };

    interface = mkOption {
      default = [
        "en*"
        "eth*"
      ];

      type = types.listOf types.str;
    };

    networkd = mkOption {
      default = !cfg.networkmanager;
      type = types.bool;
    };

    networkmanager = mkOption {
      default = config.custom.minimal;
      type = types.bool;
    };

    static = mkOption {
      default = false;
      type = types.bool;
    };

    wifi = mkOption {
      default = config.custom.minimal;
      type = types.bool;
    };

    ipv4 = {
      address = mkOption {
        default = null;
        type = with types; nullOr str;
      };

      gateway = mkOption {
        default = null;
        type = with types; nullOr str;
      };

      ppp = mkOption {
        default = false;
        type = types.bool;
      };

      prefix = mkOption {
        default = null;
        type = with types; nullOr str;
      };
    };

    ipv6 = {
      address = mkOption {
        default = null;
        type = with types; nullOr str;
      };

      gateway = mkOption {
        default = null;
        type = with types; nullOr str;
      };

      ppp = mkOption {
        default = false;
        type = types.bool;
      };

      prefix = mkOption {
        default = null;
        type = with types; nullOr str;
      };
    };
  };

  config = mkIf cfg.enable {
    #!! Imperative networking
    # https://wiki.nixos.org/wiki/Networking
    #?? nmtui or nmcli
    networking = {
      hostName = config.custom.hostname;
      useNetworkd = cfg.networkd;
      wireless.iwd.enable = cfg.wifi;

      firewall = mkIf cfg.firewall {
        enable = true;
        allowedUDPPorts = mkIf cfg.dnsmasq [53 67];
      };

      # Prefer tailscale address over 127.0.0.2 for machine hostname
      hosts = mkIf config.custom.services.tailscale.enable {
        ${config.custom.services.tailscale.ipv4} = [config.custom.hostname];
      };

      networkmanager = mkIf cfg.networkmanager {
        enable = true;
        plugins = [pkgs.networkmanager-openvpn];
        wifi.backend = mkIf cfg.wifi "iwd";
      };
    };

    users.users.${config.custom.username}.extraGroups = mkIf cfg.networkmanager ["networkmanager"];

    # Declarative networking
    # https://wiki.nixos.org/wiki/Systemd/networkd
    #?? networkctl
    #?? man systemd.network
    systemd = mkIf (!cfg.networkmanager) {
      network = {
        enable = true;

        # https://www.freedesktop.org/software/systemd/man/latest/systemd.link.html
        links."10-links" = {
          linkConfig = {
            # BUG: Some features are not exposed as systemd.link options
            # https://github.com/systemd/systemd/blob/391ad5d8aa533010bed02079c95eab34de0408c5/src/shared/ethtool-util.c#L150
            # https://github.com/systemd/systemd/blob/391ad5d8aa533010bed02079c95eab34de0408c5/src/shared/ethtool-util.c#L148
            #// GenericReceiveOffload = true;
          };

          matchConfig = {
            OriginalName = cfg.interface;
          };
        };

        networks."10-static" = mkIf cfg.static {
          address =
            optionals (!isNull cfg.ipv4.address) [
              "${cfg.ipv4.address}${cfg.ipv4.prefix}"
            ]
            ++ optionals (!isNull cfg.ipv6.address) [
              "${cfg.ipv6.address}${cfg.ipv6.prefix}"
            ];

          gateway =
            optionals (!isNull cfg.ipv4.gateway) [
              cfg.ipv4.gateway
            ]
            ++ optionals (!isNull cfg.ipv6.gateway) [
              cfg.ipv6.gateway
            ];

          linkConfig = {
            RequiredForOnline = "routable";
          };

          matchConfig = {
            Name = cfg.interface;
          };

          networkConfig =
            optionalAttrs (isNull cfg.ipv4.address) {
              DHCP = "ipv4";
            }
            // optionalAttrs (isNull cfg.ipv6.address) {
              IPv6AcceptRA = true;
            };

          routes =
            optionals cfg.ipv4.ppp [
              {
                Gateway = cfg.ipv4.gateway;
                GatewayOnLink = true;
              }
            ]
            ++ optionals cfg.ipv6.ppp [
              {
                Gateway = cfg.ipv6.gateway;
                GatewayOnLink = true;
              }
            ];
        };
      };

      # HACK: Manually set interface features via ethtool
      # https://tailscale.com/kb/1320/performance-best-practices?q=udp#linux-optimizations-for-subnet-routers-and-exit-nodes
      services.set-interface-features = {
        description = "Set interface features via ethtool";
        wants = ["network-online.target"];

        script = ''
          interface="$(${ip} -o route get 9.9.9.9 | ${cut} -d ' ' -f 5)"
          ${ethtool} -K "$interface" rx-udp-gro-forwarding on rx-gro-list off
        '';
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

      # TODO: Add testing command
      # https://quad9.net/support/faq#testing
      # https://quad9.net/service/service-addresses-and-features
      fallbackDns = mkIf cfg.dns [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
        "2620:fe::fe#dns.quad9.net"
        "2620:fe::9#dns.quad9.net"
      ];
    };

    # https://wiki.archlinux.org/title/IPv6#Prefer_IPv4_over_IPv6
    environment.etc."gai.conf".text = ''
      precedence ::ffff:0:0/96 100
    '';

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
