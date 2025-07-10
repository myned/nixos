{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "mynitor";

    services = {
      # TODO: tailscale.ip = "100.126.156.42";
    };

    settings = {
      boot.grub = {
        enable = true;
        # TODO: device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_53186364";
      };

      networking = {
        static = true;

        ipv6 = {
          # TODO: address = "2a01:4ff:f0:e193::1/64";
          gateway = "fe80::1";
        };
      };

      storage = {
        enable = true;
        swap = 8; # GiB
      };
    };
  };
}
