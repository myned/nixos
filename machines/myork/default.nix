{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myork";
    width = 2256;
    height = 1504;
    scale = 1.5;

    desktops = {
      niri.output.connectors = ["eDP-1"];
    };

    programs = {
      # BUG: Phoenix support not currently functional
      # https://github.com/Cryolitia/ryzen_smu/issues/1
      #// ryzenadj.enable = true;

      waybar = {
        temperature = {
          cpu.zone = 0;
          gpu.zone = 3;
        };
      };
    };

    services = {
      auto-cpufreq.max.battery = 3.5; # GHz
      fw-fanctrl.enable = true;

      tailscale = {
        ipv4 = "100.81.241.17";
        ipv6 = "fd7a:115c:a1e0::3801:f111";
      };
    };

    settings = {
      boot.systemd-boot.enable = true;

      hardware = {
        cpu = "amd";
        dgpu.driver = "amdgpu";
        rocm = "11.0.2"; # 11.0.3
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

    # Force display power savings
    # https://wiki.archlinux.org/title/Framework_Laptop_13#(AMD)_Washed-out_colors_when_using_power-profiles-daemon_in_power-saver_or_balanced_mode
    #// "amdgpu.abmlevel=0"

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
