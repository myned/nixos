{
  imports = [ ./hardware-configuration.nix ];

  custom.hostname = "mypi3";

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 4 * 1024; # GiB * 1024
    }
  ];
}
