{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myore";
    vm = true;

    services = {
      tailscale = {
        ipv4 = "100.85.81.198";
        ipv6 = "fd7a:115c:a1e0:82bb:75c2:e9e7:b71a:454f";
      };
    };

    settings = {
      boot.grub.enable = true;

      networking = {
        static = true;

        ipv4 = {
          address = "5.161.105.159";
          gateway = "172.31.1.1";
          ppp = true;
          prefix = "/32";
        };

        ipv6 = {
          address = "2a01:4ff:f0:d346::1";
          gateway = "fe80::1";
          ppp = true;
          prefix = "/64";
        };
      };

      storage = {
        swapSize = 8;
        root.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_100479622";
      };
    };
  };
}
