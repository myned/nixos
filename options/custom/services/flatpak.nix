{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.flatpak;
in {
  options.custom.services.flatpak.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    home-manager.users.${config.custom.username} = {
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

            # TODO: Check if in nixpkgs
            "io.github.brunofin.Cohesion" # Notion client
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
