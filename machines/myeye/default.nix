{inputs, ...}: {
  imports = [
    "${inputs.nixos-hardware}/common/cpu/intel/coffee-lake"
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myeye";

    services = {
      scrutiny.enable = true;
      smartd.enable = true;

      tailscale = {
        ipv4 = "";
        ipv6 = "";
      };
    };

    settings = {
      boot.systemd-boot.enable = true;

      storage = {
        swapSize = 32;
        root.device = "/dev/disk/by-id/?";
      };
    };
  };
}
