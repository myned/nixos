{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myarm";

    services = {
      tailscale.ip = "";
    };

    settings = {
      boot.systemd-boot.enable = true;

      networking = {
        static = true;
        ipv6 = "2a01:4f8:c17:321c::1/64";
      };
    };
  };
}
