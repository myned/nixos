{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myne";

    services = {
      tailscale.ip = "100.126.156.42";
    };

    settings = {
      boot.grub = true;

      networking = {
        static = true;
        ipv6 = "2a01:4ff:f0:e193::1/64";
      };
    };
  };
}
