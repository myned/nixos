{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  sed = "${pkgs.gnused}/bin/sed";

  cfg = config.custom.settings.boot;
in {
  options.custom.settings.boot = {
    enable = mkOption {default = false;};
    console-mode = mkOption {default = "max";};
    grub = mkOption {default = false;};
    kernel = mkOption {
      default =
        if config.custom.full
        then pkgs.linuxPackages_6_12
        else pkgs.linuxPackages;
    };
    systemd-boot = mkOption {default = config.custom.minimal;};
    timeout = mkOption {
      default =
        if config.custom.minimal
        then 2
        else 10;
    };
    u-boot = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    boot = {
      # https://wiki.nixos.org/wiki/Linux_kernel
      kernelPackages = cfg.kernel;

      kernel.sysctl = mkIf config.custom.default {
        # https://wiki.archlinux.org/title/Sysctl#Virtual_memory
        "vm.dirty_bytes" = 256 * 1024 * 1024; # 256MB
        "vm.dirty_background_bytes" = 128 * 1024 * 1024; # 128MB
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

        systemd-boot = mkIf cfg.systemd-boot {
          enable = true;
          configurationLimit = 15;
          consoleMode = mkIf (!isInt cfg.console-mode || cfg.console-mode <= 2) cfg.console-mode;
          editor = false; # Disable cmdline

          # HACK: consoleMode does not accept undocumented device modes (e.g. 3 4 5)
          extraInstallCommands = mkIf (isInt cfg.console-mode && cfg.console-mode > 2) ''
            ${sed} -i 's|console-mode.*|console-mode ${toString cfg.console-mode}|' /boot/loader/loader.conf
          '';
        };

        generic-extlinux-compatible.enable = cfg.u-boot;
        grub.enable = cfg.grub;
      };
    };

    console = mkIf config.custom.minimal {
      # Modified Solarized Dark
      # https://github.com/coderonline/base16-vtrgb/blob/master/consolecolors/base16-solarized-dark.hex
      colors = [
        "073642"
        "002b36" # Background
        "859900" # Success
        "657b83"
        "839496"
        "b58900"
        "eee8d5"
        "93a1a1" # Primary
        "dc322f"
        "cb4b16"
        "d33682" # Tertiary
        "586e75"
        "6c71c4" # Accent
        "268bd2"
        "2aa198"
        "fdf6e3" # Secondary
      ];
    };
  };
}
