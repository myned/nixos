{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.sway.output;
in {
  options.custom.desktops.sway.output.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # TODO: May need kanshi for output switching
    # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.config.output
    #?? man sway-output
    #?? swaymsg -t get_outputs
    wayland.windowManager.sway.config.output = {
      # Default
      "*" = {
        adaptive_sync = "off"; # Explicitly use script/keybindings to toggle vrr
        background = "#073642 solid_color"; # Fallback color
        resolution = "${toString config.custom.width}x${toString config.custom.height}@${toString config.custom.refresh}Hz";
        scale = toString config.custom.scale;
      };
    };
  };
}
