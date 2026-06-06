{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.sway.swayfx;
in {
  options.custom.desktops.sway.swayfx.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/WillPower3309/swayfx
        programs.sway.package = pkgs.swayfx;

        wayland.windowManager.sway = {
          # BUG: DRM build failure
          # https://github.com/nix-community/home-manager/issues/5379
          checkConfig = false;

          # Polyfill home-manager wrappers
          # https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/sway.nix#L334
          package = with config.home-manager.users.${config.custom.username}.wayland.windowManager.sway;
            config.programs.sway.package.override {
              extraSessionCommands = extraSessionCommands;
              extraOptions = extraOptions;
              withBaseWrapper = wrapperFeatures.base;
              withGtkWrapper = wrapperFeatures.gtk;
            };

          # https://github.com/WillPower3309/swayfx?tab=readme-ov-file#new-configuration-options
          extraConfig = ''
            corner_radius 12
            default_dim_inactive 0.25
            dim_inactive_colors.unfocused #002b36
            scratchpad_minimize enable
            shadows enable
            shadows_on_csd enable
            smart_corner_radius enable
            #// titlebar_separator disable
          '';
        };
      }
    ];
  };
}
