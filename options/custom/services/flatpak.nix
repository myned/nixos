{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.flatpak;
in {
  options.custom.services.flatpak.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    #!! Only takes effect if /usr/* shares do not exist
    # Nixpkgs workaround requires packages in the global environment
    # https://github.com/NixOS/nixpkgs/pull/262462
    environment.systemPackages =
      config.fonts.packages
      ++ [
        config.home-manager.users.${config.custom.username}.gtk.cursorTheme.package
        config.home-manager.users.${config.custom.username}.gtk.iconTheme.package
      ];

    home-manager.users.${config.custom.username} = {
      imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];

      # https://wiki.nixos.org/wiki/Flatpak
      # https://github.com/gmodena/nix-flatpak
      services.flatpak = {
        enable = true;
        uninstallUnmanaged = true; # Immutable flatpaks
        update.auto.enable = true; # Auto update flatpaks weekly

        #!! Installation occurs during activation
        #?? flatpak search NAME
        packages =
          optionals config.custom.default [
            "com.github.tchx84.Flatseal" # Flatpak permissions editor
          ]
          ++ optionals config.custom.minimal [
            "net.retrodeck.retrodeck" # Game emulator
          ]
          ++ optionals config.custom.full [
            "app.drey.Biblioteca" # Documentation viewer
            "io.github.ronniedroid.concessio" # Permissions converter
            "re.sonny.Workbench" # GTK prototyper
          ];

        # https://github.com/gmodena/nix-flatpak?tab=readme-ov-file#overrides
        overrides.global = {
          Context.filesystems = [
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"

            # HACK: Globally allow access to /nix/store for symlinked themes
            "/nix/store:ro"
          ];
        };
      };
    };
  };
}
