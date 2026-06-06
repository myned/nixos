{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri;
  hm = config.home-manager.users.${config.custom.username};
in {
  imports = [inputs.niri-nix.nixosModules.default];

  options.custom.desktops.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    custom.desktops = {
      tiling = true;
      dms.enable = true;
      gnome.enable = true;
      gnome.minimal = true;
      niri.binds.enable = true;
      niri.input.enable = true;
      niri.layout.enable = true;
      niri.misc.enable = true;
      niri.output.enable = true;
      niri.rules.enable = true;
    };

    # https://github.com/YaLTeR/niri
    # https://codeberg.org/BANanaD3V/niri-nix
    nixpkgs.overlays = [inputs.niri-nix.overlays.niri-nix];

    programs.niri = {
      enable = true;
      package = pkgs.niri;
      #// package = niri-unstable;
    };

    home-manager.sharedModules = [
      {
        imports = [
          inputs.niri-nix.homeModules.default
          inputs.niri-nix.homeModules.stylix
        ];

        # https://codeberg.org/BANanaD3V/niri-nix#home-manager-module
        wayland.windowManager.niri = {
          enable = true;
          package = config.programs.niri.package;

          # https://codeberg.org/BANanaD3V/niri-nix/src/branch/main/home-options.md#wayland-windowmanager-niri-settings
          # https://github.com/YaLTeR/niri/wiki/Configuration:-Debug-Options
          settings.debug =
            {
              deactivate-unfocused-windows = [];
              enable-overlay-planes = [];
              honor-xdg-activation-with-invalid-serial = [];
              keep-laptop-panel-on-when-lid-is-closed = [];
            }
            // optionalAttrs config.custom.displays.default.vrr {
              skip-cursor-only-updates-during-vrr = [];
            };
        };

        # https://codeberg.org/BANanaD3V/niri-nix/src/branch/main/modules/stylix.nix
        stylix.targets.niri.enable = true;
      }
    ];
  };
}
