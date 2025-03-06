{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd

    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "myork";
    width = 2256;
    height = 1504;
    scale = 1.5;
    desktops.niri.output.connectors = ["eDP-1"];

    # BUG: Phoenix support not currently functional
    # https://github.com/Cryolitia/ryzen_smu/issues/1
    #// programs.ryzenadj.enable = true;

    services.fw-fanctrl.enable = true;
    #// settings.storage.mnt = ["myve"];
  };

  services.keyd.keyboards.default.settings.main.rightcontrol = "layer(altgr)"; # No Ctrl_R

  boot = {
    # Enable hibernation with a swapfile on btrfs
    # https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation_into_swap_file
    #?? findmnt -no UUID -T /swap/swapfile
    resumeDevice = "/dev/disk/by-uuid/f9416347-eff5-45d5-8dc3-93414c11ba6f";

    kernelParams = [
      #?? sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
      "resume_offset=533760"

      # Fix battery drain with suspend
      # https://wiki.archlinux.org/title/Framework_Laptop_13#Suspend-then-hibernate_on_AMD_version
      "rtc_cmos.use_acpi_alarm=1"

      # Force display power savings
      # https://wiki.archlinux.org/title/Framework_Laptop_13#(AMD)_Washed-out_colors_when_using_power-profiles-daemon_in_power-saver_or_balanced_mode
      "amdgpu.abmlevel=0"

      # Disable AMD scaling driver
      # https://wiki.archlinux.org/title/CPU_frequency_scaling#amd_pstate
      #// "amd_pstate=disable"
    ];
  };

  home-manager.users.${config.custom.username} = {
    wayland.windowManager.hyprland.settings = {
      device = [
        {
          name = "pixa3854:00-093a:0274-touchpad";
          accel_profile = "adaptive";
          sensitivity = 0.3;
        }
      ];
    };
  };
}
