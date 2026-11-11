{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.incus;
in {
  options.custom.incus = {
    enable = mkEnableOption "incus";

    boot = mkOption {
      description = "Whether to start Incus at boot";
      default = false;
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Incus
    # https://linuxcontainers.org/incus/
    # https://www.nijho.lt/post/proxmox-to-nixos/
    virtualisation.incus = {
      enable = true;
      ui.enable = true; # https://canonical.com/lxd/docs/latest/howto/access_ui/
      socketActivation = !cfg.boot;

      # https://wiki.nixos.org/wiki/Incus#Preseed
      # https://linuxcontainers.org/incus/docs/main/howto/initialize/#non-interactive-configuration
      preseed = {
        # https://linuxcontainers.org/incus/docs/main/server_config/
        config = {
          "core.https_address" = ":8443";
          "images.auto_update_interval" = 24; # Hours
        };

        networks = [
          {
            # https://linuxcontainers.org/incus/docs/main/reference/network_bridge/#network-bridge
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv6.address" = "auto";
              "ipv4.nat" = true;
              "ipv6.nat" = true;
            };
          }
        ];

        storage_pools = [
          {
            # https://linuxcontainers.org/incus/docs/main/reference/storage_dir/
            name = "default";
            driver = "dir";
            config = {
              source = "/var/lib/incus/storage-pools/default";
            };
          }
        ];

        profiles = [
          {
            # https://linuxcontainers.org/incus/docs/main/profiles/
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
        ];
      };
    };

    networking.nftables.enable = true; # nftables is required
    networking.firewall.interfaces.incusbr0 = {
      allowedTCPPorts = [53 67]; # DNS, DHCP
      allowedUDPPorts = [53 67];
    };
    users.users.${config.custom.username}.extraGroups = ["incus-admin"];
  };
}
