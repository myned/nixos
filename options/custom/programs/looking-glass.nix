{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.looking-glass;
in {
  options.custom.programs.looking-glass = {
    enable = mkEnableOption "looking-glass";

    igpu = mkOption {
      default = false;
      type = types.bool;
    };

    kvmfr = mkOption {
      default = true;
      type = types.bool;
    };

    # https://looking-glass.io/docs/B7/install_libvirt/#libvirt-determining-memory
    memory = mkOption {
      default = with config.custom;
        (
          if ultrawide
          then 128
          else 64
        )
        * (
          if hdr
          then 2
          else 1
        );

      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    #!! Imperative libvirt xml configuration
    # https://looking-glass.io/
    # https://looking-glass.io/docs/B7/install/
    # BUG: CPU host-passthrough causes error on VM start
    # https://github.com/tianocore/edk2/discussions/4662
    #?? <cpu><maxphysaddr mode="passthrough" limit="40"/></cpu>

    # https://looking-glass.io/docs/B7/ivshmem_kvmfr/
    boot = mkIf cfg.kvmfr {
      extraModulePackages = [config.boot.kernelPackages.kvmfr];
      extraModprobeConfig = "options kvmfr static_size_mb=${toString cfg.memory}";
      kernelModules = ["kvmfr"];
    };

    systemd = {
      tmpfiles.settings.looking-glass = let
        owner = mode: {
          mode = "0660";
          user = config.custom.username;
          group = "qemu-libvirtd";
        };

        file =
          if cfg.kvmfr
          then "/dev/kvmfr0"
          else "/dev/shm/looking-glass";

        type =
          if cfg.kvmfr
          then "z" # Set permissions only
          else "f"; # Create file
      in {
        ${file} = {
          ${type} = owner "0660";
        };
      };

      # HACK: Remove exclusion of /dev prefix from service so rules take effect for devices
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/systemd/tmpfiles.nix
      # https://github.com/NixOS/nixpkgs/commit/e6b66f08a53261cf825817df59d3ccd75ed0eead
      services.systemd-tmpfiles-setup.serviceConfig = {
        ExecStart = mkForce "systemd-tmpfiles --create --remove --boot --exclude-prefix=/sysroot";
      };
    };

    # https://looking-glass.io/docs/B7/ivshmem_kvmfr/#libvirt
    virtualisation.libvirtd.qemu.verbatimConfig = mkIf cfg.kvmfr ''
      cgroup_device_acl = [
        "/dev/null", "/dev/full", "/dev/zero",
        "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
        "/dev/rtc", "/dev/hpet", "/dev/vfio/vfio",
        "/dev/kvmfr0"
      ]

      # Default configuration
      namespaces = []
    '';

    home-manager.sharedModules = [
      {
        programs.looking-glass-client = {
          enable = true;

          # https://looking-glass.io/docs/B7/usage/#all-command-line-options
          settings = {
            app = {
              shmFile =
                if cfg.kvmfr
                then "/dev/kvmfr0"
                else "/dev/shm/looking-glass";
            };

            egl = {
              doubleBuffer = true;
              vsync = true;
            };

            input = {
              grabKeyboard = false;
              ignoreWindowsKeys = true;
            };

            win = {
              borderless = true;
              #// fullScreen = true;
              quickSplash = true;
              #// size = "${toString (config.custom.width / 2)}x${toString (config.custom.height / 2)}";
              uiFont = config.stylix.fonts.monospace.name;
              uiSize = 24;
            };
          };
        };
      }
    ];
  };
}
