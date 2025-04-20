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

    # BUG: Phoenix support not currently functional
    # https://github.com/Cryolitia/ryzen_smu/issues/1
    programs = {
      #// ryzenadj.enable = true;
    };

    services = {
      auto-cpufreq.max.battery = 3.5; # GHz
      fw-fanctrl.enable = true;
      tailscale.ip = "100.100.119.16";
    };

    settings = {
      hardware = {
        gpu = "amd";
        rocm = "11.0.2"; # 11.0.3
      };

      storage = {
        encrypt = true;
        key.enable = true;
        #// mnt = ["myve"];
        offset = 225239338; #?? sudo btrfs inspect-internal map-swapfile -r /var/lib/swapfile
        swap = 32; # GB
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
