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
    # https://wiki.nixos.org/wiki/Cross_Compiling
    boot.binfmt.emulatedSystems = mkIf cfg.builder ["aarch64-linux"]; # Emulate architecture
    #// nixpkgs.buildPlatform = "x86_64-linux"; # Binary caches often not available

    environment = {
      localBinInPath = true;

      # HACK: Nix does not currently handle locale properly, so force default
      # https://github.com/NixOS/nixpkgs/issues/183960 et al.
      #// i18n.defaultLocale = "C.UTF-8";

      sessionVariables =
        mkIf config.custom.minimal
        {
          # https://wiki.archlinux.org/title/Wayland#Java
          _JAVA_AWT_WM_NONREPARENTING = "1";

          # Allow unfree packages by default
          #?? nix shell nixpkgs#<package> --impure
          NIXPKGS_ALLOW_UNFREE = "1";
        }
        // optionalAttrs (!config.custom.services.xwayland-satellite.enable) {
          GDK_SCALE = toString config.custom.scale; # Steam HiDPI
        }
        // optionalAttrs config.custom.desktops.tiling {
          # https://github.com/krille-chan/fluffychat/wiki/Manual#i-use-tiling-wm-how-do-i-disable-the-title-bar
          GTK_CSD = "0";
        }
        // optionalAttrs cfg.wayland {
          # https://wiki.nixos.org/wiki/Wayland#Electron_and_Chromium
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          NIXOS_OZONE_WL = "1";
        };

      shellAliases = {
        # https://github.com/aksiksi/compose2nix?tab=readme-ov-file#usage
        # https://github.com/aksiksi/compose2nix?tab=readme-ov-file#agenix
        compose2nix = concatStringsSep " " [
          "compose2nix"
          "--inputs compose.yaml"
          "--output compose.nix"
          "--root_path /containers"
          "--auto_format"
          "--check_systemd_mounts"
          "--env_files_only"
          "--ignore_missing_env_files"
          "--include_env_files"
          #?? --env_files /run/agenix/containers/*/.env
        ];
      };
    };
  };
}
