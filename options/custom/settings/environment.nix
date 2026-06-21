{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.environment;
in {
  options.custom.settings.environment = {
    enable = mkOption {default = false;};
    builder = mkOption {default = config.custom.full;};
    wayland = mkOption {default = config.custom.minimal;};
  };

  config = mkIf cfg.enable {
    time.timeZone = mkIf config.custom.server "Etc/UTC";
    i18n.defaultLocale = mkIf config.custom.server "C.UTF-8"; # Recommended for consistency
    i18n.inputMethod.ibus.waylandFrontend = true;

    # https://wiki.nixos.org/wiki/Cross_Compiling
    boot.binfmt = {
      emulatedSystems = optionals cfg.builder ["aarch64-linux"];

      # Fix binaries in chroot (nixos-enter)
      # https://github.com/NixOS/nixpkgs/issues/346504
      preferStaticEmulators = true;
    };

    #// nixpkgs.buildPlatform = "x86_64-linux"; # Binary caches often not available

    environment = {
      localBinInPath = true;
    };

    home-manager.sharedModules = [
      {
        home.sessionVariables =
          optionalAttrs config.custom.minimal {
            # https://wiki.archlinux.org/title/Wayland#Java
            _JAVA_AWT_WM_NONREPARENTING = "1";

            # https://wiki.nixos.org/wiki/GStreamer#nautilus:_%22Your_GStreamer_installation_is_missing_a_plug-in.%22
            GST_PLUGIN_PATH = "/run/current-system/sw/lib/gstreamer-1.0/";
          }
          // optionalAttrs cfg.wayland {
            # https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
            NIXOS_OZONE_WL = "1";
          }
          // {
            # Allow all unfree packages
            #?? nix shell nixpkgs#<package> --impure
            NIXPKGS_ALLOW_UNFREE = "1";
          };
      }
    ];
  };
}
