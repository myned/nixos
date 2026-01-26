{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.boot;

  sed = getExe pkgs.gnused;
in {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  options.custom.settings.boot = {
    enable = mkEnableOption "boot";

    grub = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
    };

    kernel = mkOption {
      default =
        if config.custom.full
        then pkgs.linuxPackages # _latest
        else pkgs.linuxPackages;

      type = types.attrs;
    };

    kmscon = mkOption {
      default = false;
      type = types.bool;
    };

    lanzaboote = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
    };

    plymouth = mkOption {
      default = false;
      type = types.bool;
    };

    systemd-boot = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };

      console-mode = mkOption {
        default = "max";
        type = with types; either int str;
      };
    };

    timeout = mkOption {
      default =
        if config.custom.minimal
        then 2
        else 10;

      type = types.int;
    };

    u-boot = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      # https://wiki.nixos.org/wiki/Linux_kernel
      kernelPackages = cfg.kernel;

      kernel.sysctl = mkIf config.custom.default {
        # https://wiki.archlinux.org/title/Sysctl#Virtual_memory
        "vm.dirty_bytes" = 256 * 1024 * 1024; # 256 MiB
        "vm.dirty_background_bytes" = 128 * 1024 * 1024; # 128 MiB
        "vm.vfs_cache_pressure" = 50; # Default: 100

        # https://wiki.archlinux.org/title/Swap#Swappiness
        "vm.swappiness" = 1; # Default: 60

        # https://redis.io/docs/latest/develop/get-started/faq/#background-saving-fails-with-a-fork-error-on-linux
        "vm.overcommit_memory" = 1;

        # https://docs.syncthing.net/users/faq.html#inotify-limits
        "fs.inotify.max_user_watches" = 204800;

        # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
        "net.core.rmem_max" = 7500000;
        "net.core.wmem_max" = 7500000;
      };

      loader = {
        timeout = cfg.timeout;
        efi.canTouchEfiVariables = true;

        generic-extlinux-compatible = mkIf cfg.u-boot.enable {
          enable = true;
        };

        grub = mkIf cfg.grub.enable {
          enable = true;
        };

        systemd-boot = mkIf (cfg.systemd-boot.enable || cfg.lanzaboote.enable) {
          enable = !cfg.lanzaboote.enable;
          configurationLimit = 10;
          consoleMode = mkIf (!isInt cfg.systemd-boot.console-mode || cfg.systemd-boot.console-mode <= 2) cfg.systemd-boot.console-mode;
          editor = false; # Disable interactive cmdline

          # HACK: consoleMode does not accept undocumented device modes (e.g. 3 4 5)
          extraInstallCommands = mkIf (isInt cfg.systemd-boot.console-mode && cfg.systemd-boot.console-mode > 2) ''
            ${sed} -i 's|console-mode.*|console-mode ${toString cfg.systemd-boot.console-mode}|' /boot/loader/loader.conf
          '';
        };
      };

      # https://wiki.nixos.org/wiki/Lanzaboote
      # https://github.com/nix-community/lanzaboote/blob/master/docs/introduction.md
      lanzaboote = mkIf cfg.lanzaboote.enable {
        enable = true;
        autoGenerateKeys.enable = true;
        pkiBundle = "/var/lib/sbctl";

        #!! Requires Secure Boot setup mode, dependent on UEFI firmware
        #?? bootctl status
        autoEnrollKeys = {
          enable = true;
          autoReboot = true; #!! Reboots after enrolling
        };
      };

      # https://wiki.nixos.org/wiki/Plymouth
      plymouth = optionalAttrs cfg.plymouth {
        enable = true;
      };
    };

    console = {
      #// earlySetup = true;

      # https://wiki.nixos.org/wiki/Console_Fonts
      # https://wiki.archlinux.org/title/Linux_console#Fonts
      # https://adeverteuil.github.io/linux-console-fonts-screenshots/
      #// font = "Lat2-Terminus16";
    };

    environment.systemPackages = mkIf cfg.lanzaboote.enable [pkgs.sbctl];

    # https://wiki.archlinux.org/title/KMSCON
    services.kmscon = mkIf cfg.kmscon {
      enable = true;
      hwRender = true;
    };

    stylix.targets = {
      console.enable = true; # https://nix-community.github.io/stylix/options/modules/console.html
      grub.enable = cfg.grub.enable; # https://nix-community.github.io/stylix/options/modules/grub.html
      kmscon.enable = cfg.kmscon; # https://nix-community.github.io/stylix/options/modules/kmscon.html
    };
  };
}
