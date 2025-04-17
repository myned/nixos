{config, ...}: {
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "mynix";
    width = 3440;
    height = 1440;
    refresh = 100;
    #// vrr = true;

    desktops.niri.output = {
      connectors = ["DP-1" "DP-2" "DP-3" "DP-4" "DP-5"];
      disabled = ["HDMI-A-1" "HDMI-A-2" "HDMI-A-3" "HDMI-A-4" "HDMI-A-5"];
    };

    programs.looking-glass = {
      enable = true;
      igpu = true;
    };

    services = {
      tailscale.ip = "100.67.212.39";
    };

    settings = {
      games = {
        enable = true;
        #// abiotic-factor = true;
      };

      hardware = {
        gpu = "amd";
        rocm = "10.3.0"; # 10.3.1
      };

      storage.mnt = [
        "gayme"
        "gaymer"
        #// "myve"
      ];

      vm.passthrough = {
        enable = true;
        #// blacklist = true;
        driver = "amdgpu";
        guest = "myndows";
        id = "1002:73df";
        intel = true;
        node = "pci_0000_03_00_0";
      };
    };
  };

  boot = {
    # Enable hibernation with a swapfile on btrfs
    # https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation_into_swap_file
    #?? findmnt -no UUID -T /swap/swapfile
    resumeDevice = "/dev/disk/by-uuid/5df5028b-a3ba-4f07-80ef-fd5abd542a81";

    kernelParams = [
      #?? sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
      "resume_offset=533760"

      # https://gitlab.freedesktop.org/drm/amd/-/issues/2516#note_2119750
      #// "gpu_sched.sched_policy=0" # Attempt to fix stutter
    ];
  };

  #  _._     _,-'""`-._
  # (,-.`._,'(       |\`-/|
  #     `-.-' \ )-`( , o o)
  #           `-    \`_`"'-
  #// services.logind.powerKey = "ignore"; # Disable power button

  home-manager.users.${config.custom.username} = {
    # Prevent secondary GPU reset from crashing window manager
    wayland.windowManager.hyprland.settings = {
      monitor = [
        "HDMI-A-1, disable"
        "HDMI-A-2, disable"
        "HDMI-A-3, disable"
      ];
    };
  };
}
