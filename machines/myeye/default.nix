{inputs, ...}: {
  imports = [
    "${inputs.nixos-hardware}/common/cpu/intel/coffee-lake"
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myeye";

    services = {
      #tailscale.ip = "100.126.156.42";
    };

    settings = {
      boot.systemd-boot.enable = true;

      storage = {
        enable = true;
        mnt = ["local"];
        swap = 32; # GiB
      };
    };
  };
}
