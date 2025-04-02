{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-3

    ./hardware-configuration.nix
  ];

  # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_3
  custom = {
    hostname = "mypi3";

    services = {
      borgmatic.repositories = [
        {
          path = "ssh://h1m9k594@h1m9k594.repo.borgbase.com/./repo";
          label = "mypi3";
        }
      ];
    };

    settings = {
      boot = {
        # BUG: GPU reset issues on 3B+ causing hangs, uncomment when fixed with vc4 driver
        # https://github.com/raspberrypi/linux/issues/5780
        #// kernel = pkgs.linuxPackages_rpi3;
        u-boot = true;
      };
    };
  };

  boot = {
    # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_3#HDMI_output_issue_with_kernel_~6.1_(NixOS_23.05_or_NixOS_unstable)
    kernelParams = ["cma=320M"];

    # https://github.com/raspberrypi/linux/issues/6049
    extraModprobeConfig = ''
      options brcmfmac feature_disable=0x282000 roamoff=1
    '';
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 4 * 1024; # GiB * 1024
    }
  ];
}
