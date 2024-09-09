{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "mynix";
    width = 3440;
    height = 1440;
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

  # Mount external drives on boot
  fileSystems = {
    "/mnt/gayme" = {
      device = "/dev/disk/by-label/gayme";
      options = [
        "noatime"
        "nofail"
        "users"
        "exec"
        "x-gvfs-show"
      ];
    };

    "/mnt/gaymer" = {
      device = "/dev/disk/by-label/gaymer";
      options = [
        "noatime"
        "nofail"
        "users"
        "exec"
        "x-gvfs-show"
      ];
    };
  };

  # Set mount directory permissions
  #?? TYPE PATH MODE USER GROUP AGE ARGUMENT
  systemd.tmpfiles.rules = [
    "z /mnt/gayme 0755 myned users"
    "z /mnt/gaymer 0755 myned users"
  ];

  # Work around performance issues with AMD power scaling
  # https://wiki.archlinux.org/title/AMDGPU#Screen_artifacts_and_frequency_problem
  # https://wiki.archlinux.org/title/AMDGPU#Power_profiles
  #!! cardX must match the correct gpu
  #?? lspci
  #?? ls -l /dev/dri/by-path/*-card
  #?? grep '*' /sys/class/drm/card*/device/pp_power_profile_mode
  services.udev.extraRules = ''
    KERNEL=="renderD128", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="manual", ATTR{device/pp_power_profile_mode}="1"
  '';

  # https://github.com/Zygo/bees
  # Deduplicate entire filesystem
  #?? Optimal for ~1TB total disk space
  # https://github.com/Zygo/bees/blob/master/docs/config.md#hash-table-sizing
  # services.beesd.filesystems.root = {
  #   spec = "/";
  #   verbosity = "err";
  #   extraOptions = [ "--loadavg-target" "5" ]; # Reduce threads on ~5% total processor load
  # };

  # Periodically upload current wallpaper to remote server
  # systemd.user = {
  #   services."wallpaper" = {
  #     path = with pkgs; [
  #       openssh
  #       rsync
  #       tailscale
  #       variety
  #     ];

  #     #!! Hostname dependent
  #     script = ''
  #       rsync --chown caddy:caddy "$(variety --current)" root@myarm:/srv/static/wallpaper.png
  #     '';
  #   };

  #   timers."wallpaper" = {
  #     wantedBy = [ "timers.target" ];

  #     timerConfig = {
  #       OnBootSec = "1m";
  #       OnUnitActiveSec = "1m";
  #     };
  #   };
  # };
}
