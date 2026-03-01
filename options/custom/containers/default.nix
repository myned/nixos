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
            enableAgenix = mkOption {
              description = "Whether to prepare the container for decrypting agenix secrets";
              default = hostCfg.custom.files.agenix.enable;
              example = false;
              type = types.bool;
            };

            enableTailscale = mkOption {
              description = "Whether to provision the container with a Tailscale sidecar, requires auth key via agenix";
              default = hostCfg.custom.services.tailscale.enable;
              example = false;
              type = types.bool;
            };

            stateDir = mkOption {
              description = "Path to the directory on the host in which to persist systemd container state";
              default = "/var/lib/machines/${name}";
              example = "/mnt/container";
              type = types.path;
            };
          };

          config = with inputs.nix-net-lib.lib; let
            # HACK: Use first 3 characters of MD5-hashed container name as integer seed for network index, max: fff = 4095
            # https://github.com/NixOS/nix/issues/7578
            index = (builtins.fromTOML "i = 0x${substring 0 3 (builtins.hashString "md5" name)}").i;
          in {
            # Container defaults
            autoStart = true;
            ephemeral = true; #!! Stateful directories must be bind mounted to persist
            privateNetwork = true;
            privateUsers = "pick"; # https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html#User%20Namespacing%20Options
            enableTun = containerCfg.enableTailscale;

            # TODO: Consider nixos-nspawn as alternative
            # https://github.com/fpletz/nixos-nspawn
            # https://github.com/NixOS/rfcs/blob/master/rfcs/0108-nixos-containers.md
            # HACK: nixos-containers do not make networking available until after container is ready, so notify immediately
            # https://github.com/NixOS/nixpkgs/issues/69414
            # https://github.com/NixOS/nixpkgs/issues/75951#issuecomment-3298721800
            extraFlags = ["--notify-ready=no"];

            # Generate addresses for all containers
            hostAddress = optionalString containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv4Network 1)).addressNoMask;
            hostAddress6 = optionalString containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv6Network 1)).addressNoMask;
            localAddress = optionalString containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv4Network index)).addressNoMask;
            localAddress6 = optionalString containerCfg.privateNetwork (decompose (assignAddress' cfg.ipv6Network index)).addressNoMask;

            bindMounts =
              # Persist systemd service state with user namespace mapping
              # https://github.com/NixOS/nixpkgs/issues/329530
              # https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html#Mount%20Options
              {
                "/var/lib:idmap" = {
                  hostPath = containerCfg.stateDir;
                  isReadOnly = false;
                };
              }
              # Mount host agenix keys in container
              // optionalAttrs containerCfg.enableAgenix (listToAttrs (forEach containerCfg.config.age.identityPaths (
                path:
                  nameValuePair "${path}:rootidmap" {
                    hostPath = path;
                    isReadOnly = true;
                  }
              )));

            config = {
              imports = optionals containerCfg.enableAgenix [inputs.agenix.nixosModules.default];

              system.stateVersion = mkForce hostCfg.system.stateVersion; #!! DO NOT MODIFY

              # Sane default networking
              systemd.network.enable = true; #?? networkctl
              systemd.network.wait-online.enable = false; # Unmanaged interfaces
              services.resolved.enable = true; #?? resolvectl
              networking.nameservers = ["9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9"]; # https://quad9.net/service/service-addresses-and-features/

              # BUG: Containers copy host resolv.conf despite privateNetwork, breaking DNS resolution
              # https://github.com/NixOS/nixpkgs/issues/162686
              networking.useHostResolvConf = false;

              # Enable and provision Tailscale
              networking.hostName = optionalString containerCfg.enableTailscale "${hostCfg.custom.hostname}-${name}"; #?? <hostname>-<container>

              services.tailscale = mkIf containerCfg.enableTailscale {
                enable = true;
                #// interfaceName = "userspace-networking";
                extraUpFlags = ["--advertise-tags=tag:container"];
                authKeyFile = mkIf containerCfg.enableAgenix containerCfg.config.age.secrets."common/tailscale/container.key".path;

                authKeyParameters = {
                  ephemeral = true;
                  preauthorized = true;
                };
              };

              age.secrets = mkIf (with containerCfg; enableAgenix && enableTailscale) (listToAttrs (map (name: {
                  inherit name;
                  value = {file = "${inputs.self}/secrets/${name}";};
                })
                [
                  "common/tailscale/container.key"
                ]));

              # Use host ssh keys for decryption
              age.identityPaths = optionals containerCfg.enableAgenix hostCfg.age.identityPaths;
            };
          };
        }));
    };
  };

  config = mkIf cfg.enable {
    custom.services.borgmatic.sources = mapAttrsToList (name: containerCfg: containerCfg.stateDir) config.containers;

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
      externalIP = config.custom.settings.networking.ipv4.address;
      externalIPv6 = config.custom.settings.networking.ipv6.address;
    };

    # Precreate container state directories
    systemd.tmpfiles.settings =
      mapAttrs' (
        name: containerCfg:
          nameValuePair name {
            ${containerCfg.stateDir}.d = {mode = "0750";}; # -rwxr-x---
          }
      )
      config.containers;
  };
}
