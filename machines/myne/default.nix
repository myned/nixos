{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myne";

    settings = {
      boot.grub = true;

      networking = {
        static = true;
        ipv6 = "2a01:4ff:f0:e193::1/64";
      };
    };
  };
}
