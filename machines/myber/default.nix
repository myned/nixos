{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3 # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/intel-core-ultra-series3
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myber";

    displays.outputs = {
      eDP-1 = {
        model = "China Star Optoelectronics Technology Co., Ltd MND508ZB1-1 Unknown";
        width = 2880;
        height = 1920;
        refresh = 120;
        scale = 2.0;
      };

      #   DP-10 = {
      #     model = "Dell Inc. DELL S3425DW 26M7GD4";
      #     width = 3440;
      #     height = 1440;
      #     refresh = 120;
      #     scale = 1.1;
      #   };

      #   DP-12 = {
      #     model = "Dell Inc. DELL P2422HE 6Z8G3V3";
      #     width = 1920;
      #     height = 1080;
      #     refresh = 75;
      #     transform = "90";
      #     forceAtBoot = true;
      #   };
    };

    services = {
      #// fw-fanctrl.enable = true;
      tailscale.ipv4 = "100.93.55.83";
      tailscale.ipv6 = "fd7a:115c:a1e0::6139:3754";
    };

    settings = {
      boot.lanzaboote.enable = true;
      packages.extra = [inputs.fprint-clear.packages.${pkgs.system}.default];

      hardware = {
        cpu = "intel";
        igpu.driver = "xe";
      };

      storage = {
        root.device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_25515R805083";
        root.encrypted = true;
        swapSize = 16;
      };
    };
  };

  services = {
    keyd.keyboards.builtin = {
      ids = ["0001:0001:09b4e68d"];
      settings = recursiveUpdate config.services.keyd.keyboards.default.settings {
        main.rightcontrol = "layer(alt)"; # rightalt
      };
    };
  };
}
