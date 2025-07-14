{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myeck";

    services = {
      tailscale = {
        ipv4 = "100.73.230.39";
        ipv6 = "fd7a:115c:a1e0::fa01:e627";
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
