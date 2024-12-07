{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.looking-glass;
in {
  options.custom.programs.looking-glass = {
    enable = mkOption {default = false;};
    kvmfr = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    #!! Imperative libvirt xml configuration
    # https://looking-glass.io/
    # https://looking-glass.io/docs/B6/install/
    # BUG: CPU host-passthrough causes error on VM start
    # https://github.com/tianocore/edk2/discussions/4662
    #?? <cpu><maxphysaddr mode="passthrough" limit="40"/></cpu>

    # https://looking-glass.io/docs/B6/module/#kernel-module
    boot = mkIf cfg.kvmfr {
      extraModulePackages = [config.boot.kernelPackages.kvmfr];
      extraModprobeConfig = "options kvmfr static_size_mb=128";
      kernelModules = ["kvmfr"];
    };

    systemd = {
      tmpfiles.settings."10-looking-glass" = {
        ${
          if cfg.kvmfr
          then "/dev/kvmfr0"
          else "/dev/shm/looking-glass"
        } = {
          ${
            if cfg.kvmfr
            then "z"
            else "f"
          } = {
            mode = "0660";
            user = config.custom.username;
            group = "qemu-libvirtd";
          };
        };
      };

      # HACK: Remove exclusion of /dev prefix from service so rules take effect for devices
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/systemd/tmpfiles.nix
      # https://github.com/NixOS/nixpkgs/commit/e6b66f08a53261cf825817df59d3ccd75ed0eead
      services.systemd-tmpfiles-setup.serviceConfig = {
        ExecStart = mkForce "systemd-tmpfiles --create --remove --boot --exclude-prefix=/sysroot";
      };
    };

    # https://looking-glass.io/docs/B6/module/#libvirt
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

    home-manager.users.${config.custom.username} = {
      # BUG: Crashes when reconnecting to spice channel
      programs.looking-glass-client = {
        enable = true;

        # https://looking-glass.io/docs/B6/usage/#all-command-line-options
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

          spice = {
            # BUG: SPICE audio causes disconnections, remove with QEMU >= 9.1.2
            # https://gitlab.com/qemu-project/qemu/-/commit/8d9c6f6fa9eebd09ad8d0b4b4de4a0ec57e756d1
            audio = false;
          };

          win = {
            borderless = true;
            fullScreen = true;
            quickSplash = true;
            size = "${toString (config.custom.width / 2)}x${toString (config.custom.height / 2)}";
            uiFont = config.custom.font.monospace;
            uiSize = 24;
          };
        };
      };
    };
  };
}
