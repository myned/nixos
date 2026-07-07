{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd # https://github.com/NixOS/nixos-hardware/tree/master/framework/13-inch/7040-amd
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myork";

    displays.outputs = rec {
      eDP-1 = rec {
        model = "BOE 0x0BCA Unknown";
        x = 0; # Leftmost
        y = floor (DP-9.height / DP-9.scale - height / scale); # Bottom-aligned
        width = 2256;
        height = 1504;
        scale = 1.5;
      };

      DP-10 = rec {
        model = "Dell Inc. DELL P2422HE 6Z8G3V3";
        x = floor (eDP-1.width / eDP-1.scale); # Left
        y = floor (DP-9.height / DP-9.scale - height); # Bottom-aligned
        width = 1920;
        height = 1080;
        refresh = 75;
        force = true;
      };

      DP-9 = {
        model = "Dell Inc. DELL S3425DW 26M7GD4";
        x = floor (eDP-1.width / eDP-1.scale + DP-10.width); # Center
        y = 0;
        width = 3440;
        height = 1440;
        finalRefresh = 99.982;
        scale = 1.1;
      };
    };

    programs = {
      # BUG: Phoenix support not currently functional
      # https://github.com/Cryolitia/ryzen_smu/issues/1
      #// ryzenadj.enable = true;

      waybar = {
        temperature = {
          cpu.zone = 3;
          gpu.sensor = "/sys/class/hwmon/hwmon1/temp1_input";
        };
      };
    };

    services = {
      auto-cpufreq.max.battery = 3.5; # GHz
      fw-fanctrl.enable = true;

      tailscale = {
        ipv4 = "100.71.22.19";
        ipv6 = "fd7a:115c:a1e0::3101:1613";
      };
    };

    settings = {
      boot.lanzaboote.enable = true;
      packages.extra = [inputs.fprint-clear.packages.${pkgs.system}.default];

      hardware = {
        cpu = "amd";
        dgpu.driver = "amdgpu";
        igpu.driver = "amdgpu";
        #// rocm = "11.0.2"; # 11.0.3
      };

      storage = {
        defaultMounts = ["/dev/disk/by-label/myve"];
        swapSize = 32;
        #// key.enable = true;

        root = {
          device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_23414P805868";
          encrypted = true;
        };
      };
    };
  };

  boot.kernelParams = [
    # Disable AMD scaling driver
    # https://wiki.archlinux.org/title/CPU_frequency_scaling#amd_pstate
    #// "amd_pstate=disable"

    # Set maximum brightness adjustment
    # https://wiki.archlinux.org/title/Framework_Laptop_13#(AMD)_Washed-out_colors_when_using_power-profiles-daemon_in_power-saver_or_balanced_mode
    "amdgpu.abmlevel=1" # 0-4

    # Attempt to fix battery drain with suspend
    # https://wiki.archlinux.org/title/Framework_Laptop_13#Suspend-then-hibernate_on_AMD_version
    #// "rtc_cmos.use_acpi_alarm=1"

    # Attempt to fix graphical slowdowns
    # https://gitlab.freedesktop.org/drm/amd/-/issues/3647
    #// "amdgpu.dcdebugmask=0x10"

    # Attempt to fix display flickering
    #// "amdgpu.sg_display=0"

    # Attempt to fix corruption when resuming from suspend
    # https://github.com/NixOS/nixos-hardware/issues/1348
    #// "pcie_aspm=off"
  ];

  services = {
    keyd.keyboards.builtin = {
      ids = ["0001:0001:70533846"];
      settings = recursiveUpdate config.services.keyd.keyboards.default.settings {
        main.rightcontrol = "layer(altgr)"; # Alt_R
      };
    };
  };
}
