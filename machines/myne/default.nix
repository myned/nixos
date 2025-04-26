{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myne";

    services = {
      tailscale.ip = "100.126.156.42";
    };

    settings = {
      boot.grub = {
        enable = true;
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_53186364";
      };

      networking = {
        static = true;
        ipv6 = "2a01:4ff:f0:e193::1/64";
      };

      storage = {
        enable = true;
        mnt = ["local"];
        swap = 8; # GiB
      };
    };
  };
}
