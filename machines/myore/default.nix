{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myore";

    services = {
      tailscale = {
        ipv4 = "100.124.104.94";
        ipv6 = "fd7a:115c:a1e0::1:6860";
      };
    };

    settings = {
      boot.grub.enable = true;

      networking = {
        static = true;

        ipv6 = {
          address = "2a01:4ff:f0:d346::1/64";
          gateway = "fe80::1";
        };
      };

      storage = {
        swapSize = 8;
        root.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_100479622";
      };
    };
  };
}
