{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myeck";

    services = {
      tailscale = {
        ipv4 = "100.111.194.165";
        ipv6 = "fd7a:115c:a1e0:4fcf:3e5f:1be0:1108:3c3f";
      };
    };

    settings = {
      boot.systemd-boot.enable = true;

      storage = {
        swapSize = 16;
        root.device = "/dev/disk/by-id/nvme-KINGSTON_OM3PDP3512B-A01_50026B7685DF927E";
      };
    };
  };
}
