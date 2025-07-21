{
  config,
  inputs,
  ...
}: {
  imports = [
    "${inputs.nixos-hardware}/common/cpu/intel/alder-lake"
    "${inputs.nixos-hardware}/common/gpu/amd"
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "mynix";
    width = 3440;
    height = 1440;
    refresh = 75;

    programs = {
      looking-glass.enable = true;

      waybar = {
        temperature = {
          cpu.zone = 0;
          gpu.sensor = "/sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/0000:02:00.0/0000:03:00.0/hwmon/hwmon0/temp1_input";
        };
      };
    };

    services = {
      tailscale = {
        ipv4 = "100.67.212.39";
        ipv6 = "fd7a:115c:a1e0::6b03:d427";
      };
    };

    settings = {
      boot.systemd-boot.enable = true;

      hardware = {
        cpu = "intel";
        rocm = "10.3.0"; # 10.3.1

        display = with config.custom; {
          forceModes = true;

          outputs = {
            DP-1 = {
              width = 1920;
              height = 1200;
              refresh = 60;
              finalRefresh = 60;
              scale = 1;
              vrr = false;
              force = false;

              position = {
                x = width;
                y = 0;
              };
            };

            DP-2 = {
              inherit width height refresh scale vrr;
              finalRefresh = 74.979;
              force = true;

              # BUG: Cursor updates cause refresh rate fluctuation, so disable for now
              # https://github.com/YaLTeR/niri/issues/1214
              #// vrr = true;

              position = {
                x = 0;
                y = 0;
              };
            };
          };
        };

        dgpu = {
          driver = "amdgpu";
          node = "pci-0000:03:00.0";

          ids = [
            #// "1002:73df" # amdgpu
            "1002:ab28" # snd_hda_intel
          ];
        };

        igpu = {
          driver = "i915";
          node = "pci-0000:00:02.0";
        };
      };

      storage = {
        swapSize = 32;
        key.enable = true;

        defaultMounts = [
          "/dev/disk/by-label/gaymes1"
          "/dev/disk/by-label/gaymes2"
        ];

        root = {
          device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S5H7NS1NB31826A";
          encrypted = true;
        };
      };

      # vm.passthrough = {
      #   enable = true;
      #   blacklist = true;
      #   guest = "myndows";
      # };
    };
  };

  # https://www.kernel.org/doc/html/v4.20/gpu/amdgpu.html
  # https://dri.freedesktop.org/docs/drm/gpu/amdgpu/display/dc-debug.html
  boot.kernelParams = [
    # https://wiki.archlinux.org/title/AMDGPU#Frozen_or_unresponsive_display_(flip_done_timed_out)
    "amdgpu.dcdebugmask=0x10" # Attempt to fix random freezes by disabling panel self refresh
  ];

  #  _._     _,-'""`-._
  # (,-.`._,'(       |\`-/|
  #     `-.-' \ )-`( , o o)
  #           `-    \`_`"'-
  #// services.logind.powerKey = "ignore"; # Disable power button
}
