{inputs, ...}: {
  imports = [
    "${inputs.nixos-hardware}/common/cpu/intel/broadwell"
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myosh";

    services = {
      scrutiny.enable = true;
      smartd.enable = true;

      tailscale = {
        ipv4 = "100.102.109.125";
        ipv6 = "fd7a:115c:a1e0::9d01:6d82";
      };
    };

    settings = {
      boot.systemd-boot.enable = true;

      storage = {
        swapSize = 32;
        root.device = "/dev/disk/by-id/ata-KINGSTON_SUV500240G_50026B7682FAAC98";

        raid = {
          enable = true;
          type = "raid10";

          devices = [
            "/dev/disk/by-id/ata-WDC_WD1005FBYZ-01YCBB2_WD-WMC6N0M1KH5H"
            "/dev/disk/by-id/ata-WDC_WD1005FBYZ-01YCBB3_WD-WCC6M4LKJXY0"
            "/dev/disk/by-id/ata-WDC_WD10EZEX-08WN4A0_WD-WCC6Y0SY2VYS"
            "/dev/disk/by-id/ata-WDC_WD10EZEX-60WN4A1_WD-WCC6Y6PN8CPL"
          ];
        };
      };
    };
  };
}
