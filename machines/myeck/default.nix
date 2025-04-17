{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myeck";

    services = {
      tailscale.ip = "100.73.230.39";
    };
  };
}
