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
      dms.enable = true;
      niri.binds.enable = true;
      niri.input.enable = true;
      niri.layout.enable = true;
      niri.misc.enable = true;
      niri.output.enable = true;
      niri.rules.enable = true;
    };

    # https://codeberg.org/BANanaD3V/niri-nix
    nixpkgs.overlays = [inputs.niri-nix.overlays.niri-nix];

    # https://github.com/YaLTeR/niri
    programs.niri = {
      enable = true;
      package = pkgs.niri;
      #// package = niri-unstable;
    };

    # https://github.com/niri-wm/niri/wiki/Xwayland
    environment.systemPackages = [pkgs.xwayland-satellite];

    services.gnome.core-os-services.enable = true;
    xdg.portal.wlr.enable = true;
    xdg.portal.config.common.default = ["wlr" "gnome" "gtk"];

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

          # https://danklinux.com/docs/dankmaterialshell/compositors#niri-configuration
          extraConfig = mkIf config.custom.desktops.dms.enable ''
            include "dms/alttab.kdl"
            include "dms/binds.kdl"
            include "dms/colors.kdl"
            include "dms/cursor.kdl"
            // include "dms/layout.kdl"
            include "dms/outputs.kdl"
            include "dms/windowrules.kdl"
            include "dms/wpblur.kdl"
          '';
        };

        # https://codeberg.org/BANanaD3V/niri-nix/src/branch/main/modules/stylix.nix
        stylix.targets.niri.enable = true;
      }
    ];
  };
}
