{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers;
  hostCfg = config;
in {
  options = {
    custom.containers = {
      enable = mkEnableOption "containers";

      ipv4Network = mkOption {
        description = "Network of the IPv4 subnet to translate within privateNetwork containers";
        default = "10.255.0.0/16";
        example = "192.168.1.0/24";
        type = types.str;
      };

      ipv6Network = mkOption {
        description = "Network of the IPv6 prefix to translate within privateNetwork containers";
        default = "fc00::/64";
        example = "fe80::/64";
        type = types.str;
      };
    };

    containers = mkOption {
      type = with types;
        attrsOf (submodule ({
          config,
          name,
          ...
        }: let
          containerCfg = config;
        in {
          options = {
            stateDir = mkOption {
              description = "Path to the directory on the host in which to persist systemd container state";
              default = "/var/lib/machines/${name}";
              example = "/mnt/container";
              type = types.path;
            };

            dataDir = mkOption {
              description = "Path to the directory in which to store stateful data, requires manual bind mount";
              default = null;
              example = "/mnt/container";
              type = with types; nullOr path;
            };

            agenix = {
              enable = mkEnableOption "agenix";

              secrets = mkOption {
                description = "Agenix secrets to bind mount into the container, decrypted by the host";
                default = [];
                example = ["secret.key"];
                type = with types; listOf str;
              };
            };

            tailscale = {
              enable = mkEnableOption "tailscale";

              authKeySecret = mkOption {
                description = "Name of the agenix secret to the auth-key for provisioning Tailscale within the container";
                default = "common/tailscale/container.key";
                example = "tailscale.key";
                type = types.str;
              };
            };
          };

          config = with inputs.nix-net-lib.lib; let
            # HACK: Use first 3 characters of MD5-hashed container name as integer seed for network index, max: fff = 4095
            # https://github.com/NixOS/nix/issues/7578
            index = (builtins.fromTOML "i = 0x${substring 0 3 (builtins.hashString "md5" name)}").i;
          in {
            # Container defaults
            autoStart = mkDefault true;
            ephemeral = mkDefault true; #!! Stateful directories must be bind mounted to persist
            privateNetwork = mkDefault true;
            privateUsers = mkDefault "pick"; # https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html#User%20Namespacing%20Options
            agenix.enable = mkDefault true;
            tailscale.enable = mkDefault containerCfg.privateNetwork;
            enableTun = mkDefault containerCfg.tailscale.enable;

            agenix.secrets = optionals containerCfg.tailscale.enable [containerCfg.tailscale.authKeySecret];

            # TODO: Consider nixos-nspawn as alternative
            # https://github.com/fpletz/nixos-nspawn
            # https://github.com/NixOS/rfcs/blob/master/rfcs/0108-nixos-containers.md
            # HACK: nixos-containers do not make networking available until after container is ready, so notify immediately
            # https://github.com/NixOS/nixpkgs/issues/69414
            # https://github.com/NixOS/nixpkgs/issues/75951#issuecomment-3298721800
            extraFlags = ["--notify-ready=no"];

            # Generate addresses for all containers
            hostAddress = mkIf containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv4Network 1)).addressNoMask;
            hostAddress6 = mkIf containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv6Network 1)).addressNoMask;
            localAddress = mkIf containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv4Network index)).addressNoMask;
            localAddress6 = mkIf containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv6Network index)).addressNoMask;

            bindMounts = let
              # Gather secrets defined for the container
              containerSecrets = filterAttrs (name: _: elem name containerCfg.agenix.secrets) hostCfg.age.secrets;
            in
              # Persist systemd service state with user namespace mapping
              # https://github.com/NixOS/nixpkgs/issues/329530
              # https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html#Mount%20Options
              {
                "/var/lib:idmap" = {
                  hostPath = containerCfg.stateDir;
                  isReadOnly = false;
                };
              }
              # HACK: Agenix store paths are currently dependent on the host generation, so decrypt and bind mount from host, otherwise all containers with secrets are restarted with any system change
              # https://github.com/ryantm/agenix/pull/132
              // mapAttrs' (_: secret:
                nameValuePair "${secret.path}:idmap" {
                  hostPath = "/run/machines/${name}/${secret.name}"; # Original secret path can still be used in the container
                  isReadOnly = true;
                })
              containerSecrets;

            config = {
              system.stateVersion = mkForce hostCfg.system.stateVersion; #!! DO NOT MODIFY
              i18n.defaultLocale = "C.UTF-8"; # Standardize locale

              # Sane default networking with DoT
              systemd.network.enable = true; #?? networkctl
              systemd.network.wait-online.enable = false; # Unmanaged interfaces
              services.resolved.enable = true; #?? resolvectl
              services.resolved.dnsovertls = "true";

              # https://quad9.net/service/service-addresses-and-features/
              networking.nameservers = [
                "9.9.9.9#dns.quad9.net"
                "149.112.112.112#dns.quad9.net"
                "2620:fe::fe#dns.quad9.net"
                "2620:fe::9#dns.quad9.net"
              ];

              # BUG: Containers copy host resolv.conf despite privateNetwork, breaking DNS resolution
              # https://github.com/NixOS/nixpkgs/issues/162686
              networking.useHostResolvConf = false;

              # Enable and provision Tailscale
              networking.hostName = mkIf containerCfg.tailscale.enable "${hostCfg.custom.hostname}-${name}"; #?? <hostname>-<container>
              networking.firewall.trustedInterfaces = optionals containerCfg.tailscale.enable [containerCfg.config.services.tailscale.interfaceName]; # Rely on Tailscale ACLs for firewall

              services.tailscale = mkIf containerCfg.tailscale.enable {
                enable = true;
                #// interfaceName = "userspace-networking";
                extraUpFlags = ["--advertise-tags=tag:container"];
                authKeyFile = mkIf containerCfg.agenix.enable hostCfg.age.secrets.${containerCfg.tailscale.authKeySecret}.path;
                authKeyParameters.ephemeral = true;
                authKeyParameters.preauthorized = true;
              };
            };
          };
        }));
    };
  };

  config = mkIf cfg.enable {
    # Add container state directories to backup sources
    custom.services.borgmatic.sources = mapAttrsToList (_: containerCfg: containerCfg.stateDir) hostCfg.containers;

    # Add container secrets to host config
    custom.files.agenix.secrets = flatten (mapAttrsToList (_: containerCfg: containerCfg.agenix.secrets) hostCfg.containers);

    # https://wiki.nixos.org/wiki/NixOS_Containers
    # https://wiki.archlinux.org/title/Systemd-nspawn
    #?? machinectl
    virtualisation.containers.enable = true;

    # Translate container IP to host IP for network access
    networking.nat = {
      enable = true;
      enableIPv6 = true;
      internalIPs = [cfg.ipv4Network];
      internalIPv6s = [cfg.ipv6Network];
      externalIP = hostCfg.custom.settings.networking.ipv4.address;
      externalIPv6 = hostCfg.custom.settings.networking.ipv6.address;
    };

    systemd.tmpfiles.settings =
      mapAttrs' (
        name: containerCfg: let
          containerSecrets = filterAttrs (name: _: elem name containerCfg.agenix.secrets) hostCfg.age.secrets;
        in
          nameValuePair name ({
              # Precreate container state directories
              ${containerCfg.stateDir}.d = {mode = "0750";}; # -rwxr-x---
              ${containerCfg.dataDir}.d = mkIf (containerCfg.dataDir != null) {mode = "0750";}; # -rwxr-x---
            }
            # HACK: Copy secrets content to support bind mounts with tmpfiles cleanup
            # https://github.com/ryantm/agenix/issues/145
            // mapAttrs' (_: secret:
              nameValuePair "/run/machines/${name}/${secret.name}" {
                "C+" = {
                  mode = secret.mode;
                  user = secret.owner;
                  group = secret.group;
                  argument = secret.path;
                };
              })
            containerSecrets)
      )
      hostCfg.containers;
  };
}
