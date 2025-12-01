{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.hyprpaper;
in {
  options.custom.services.hyprpaper = {
    enable = mkEnableOption "hyprpaper";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper
        # https://github.com/hyprwm/hyprpaper
        services.hyprpaper = {
          enable = true;

          settings = {
            preload = ["/tmp/altered.png"];
            wallpaper = [", /tmp/altered.png"];
          };
        };

        # https://nix-community.github.io/stylix/options/modules/hyprpaper.html
        stylix.targets.hyprpaper.enable = true;
      }
    ];
  };
}
