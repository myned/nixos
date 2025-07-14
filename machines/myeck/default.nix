{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myeck";

    services = {
      tailscale.ip = "100.73.230.39";
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
