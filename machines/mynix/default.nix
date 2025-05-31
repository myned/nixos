{
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "mynix";
    width = 3440;
    height = 1440;
    refresh = 73.995;

    # BUG: Cursor updates cause refresh rate fluctuation, so disable for now
    # https://github.com/YaLTeR/niri/issues/1214
    #// vrr = true;

    desktops = {
      niri.output = {
        connectors = ["DP-1" "DP-2" "DP-3" "DP-4" "DP-5"];
        disabled = ["HDMI-A-1" "HDMI-A-2" "HDMI-A-3" "HDMI-A-4" "HDMI-A-5"];
      };
    };

    programs = {
      looking-glass.enable = true;
    };

    services = {
      tailscale.ip = "100.67.212.39";
    };

    settings = {
      boot.systemd-boot.enable = true;

      games = {
        enable = true;
        #// abiotic-factor = true;
      };

      hardware = {
        cpu = "intel";
        rocm = "10.3.0"; # 10.3.1
        display.forceModesFor = ["DP-1" "DP-2" "DP-3" "DP-4" "DP-5"];

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
        encrypt = true;
        key.enable = true;
        offset = 30753211; #?? sudo btrfs inspect-internal map-swapfile -r /var/lib/swapfile
        swap = 32; # GiB

        mnt = [
          "gayme"
          #// "gaymer"
          "myve"
        ];
        ];
      };

      # vm.passthrough = {
      #   enable = true;
      #   blacklist = true;
      #   guest = "myndows";
      # };
    };
  };

  boot.kernelParams = [
    # https://gitlab.freedesktop.org/drm/amd/-/issues/2516#note_2119750
    #// "gpu_sched.sched_policy=0" # Attempt to fix stutter
  ];

  #  _._     _,-'""`-._
  # (,-.`._,'(       |\`-/|
  #     `-.-' \ )-`( , o o)
  #           `-    \`_`"'-
  #// services.logind.powerKey = "ignore"; # Disable power button
}
