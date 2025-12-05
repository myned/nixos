{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myork";
    width = 2256;
    height = 1504;
    scale = 1.5;

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
      scrutiny.enable = true;
      smartd.enable = true;

      tailscale = {
        ipv4 = "100.71.22.19";
        ipv6 = "fd7a:115c:a1e0::3101:1613";
      };
    };

    settings = {
      boot.systemd-boot.enable = true;
      packages.extra = [inputs.fprint-clear.packages.${pkgs.system}.default];

      hardware = {
        cpu = "amd";
        dgpu.driver = "amdgpu";
        igpu.driver = "amdgpu";
        rocm = "11.0.2"; # 11.0.3

        outputs = with config.custom; let
          left = {
            x = width / scale - 1920;
            y = 0;
            width = 1920;
            height = 1080;
            scale = 1;
            refresh = 75;
            finalRefresh = 74.977;
            force = true;
            main = true;
            vrr = false;
          };

          right = {
            x = width / scale;
            y = 0;
            width = 1920;
            height = 1080;
            scale = 1;
            refresh = 75;
            finalRefresh = 74.977;
            force = true;
            main = true;
            vrr = false;
          };
        in {
          eDP-1 = {
            inherit width height refresh scale vrr;
            x = 0;
            y = 0;
            finalRefresh = refresh;
            force = false;
            main = true;
          };

          # HACK: Work around outputs not being removed when disconnected
          # https://github.com/YaLTeR/niri/issues/1722
          DP-9 = right;
          DP-10 = left;
          DP-11 = right;
          DP-12 = left;
          DP-13 = right;
          DP-14 = left;
          DP-15 = right;
          DP-16 = left;
        };
      };

      storage = {
        defaultMounts = ["/dev/disk/by-label/myve"];
        swapSize = 32;
        key.enable = true;

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
    keyd.keyboards.default.settings.main.rightcontrol = "layer(altgr)"; # Alt_R
  };
}
