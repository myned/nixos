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

    games = {
      steamDir = "/mnt/gaymes1/steam/steamapps/compatdata";
    };

    programs = {
      looking-glass.enable = true;

      waybar = {
        temperature = {
          cpu.zone = 0;
          gpu.zone = 1;
        };
      };
    };

    services = {
      tailscale = {
        ipv4 = "100.71.53.26";
        ipv6 = "fd7a:115c:a1e0:e166:b2d9:e5cf:82e4:63a4";
      };
    };

    settings = {
      boot.systemd-boot.enable = true;

      hardware = {
        cpu = "intel";
        rocm = "10.3.0"; # 10.3.1

        outputs = with config.custom; {
          DP-1 = {
            x = width;
            y = 0;
            width = 1920;
            height = 1200;
            refresh = 60;
            finalRefresh = 60;
            scale = 1;
            vrr = false;
            force = false;
          };

          DP-2 = {
            inherit width height refresh scale vrr;
            x = 0;
            y = 0;
            finalRefresh = 74.979;
            force = true;

            # BUG: Cursor updates cause refresh rate fluctuation, so disable for now
            # https://github.com/YaLTeR/niri/issues/1214
            #// vrr = true;
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
    #// "amdgpu.dcdebugmask=0x10" # Attempt to fix random freezes by disabling panel self refresh
  ];

  # Work around performance issues with amdgpu power scaling
  # https://wiki.archlinux.org/title/AMDGPU#Screen_artifacts_and_frequency_problem
  # https://wiki.archlinux.org/title/AMDGPU#Power_profiles
  # 0=BOOTUP_DEFAULT 1=3D_FULL_SCREEN 2=POWER_SAVING 3=VIDEO 4=VR 5=COMPUTE 6=CUSTOM
  #!! cardX or renderX must match the correct gpu
  #?? lspci
  #?? ls -l /dev/dri/by-path/*
  #?? sudo udevadm trigger /dev/dri/by-path/*
  #?? grep '*' /sys/class/drm/card*/device/pp_power_profile_mode
  services.udev.extraRules = ''
    KERNEL=="renderD129", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="manual", ATTR{device/pp_power_profile_mode}="4"
  '';

  #  _._     _,-'""`-._
  # (,-.`._,'(       |\`-/|
  #     `-.-' \ )-`( , o o)
  #           `-    \`_`"'-
  #// services.logind.powerKey = "ignore"; # Disable power button
}
