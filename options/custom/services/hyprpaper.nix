{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.custom.services.hyprpaper;
in
{
  options.custom.services.hyprpaper.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.hyprland.org/Hypr-Ecosystem/hyprpaper
    # https://github.com/hyprwm/hyprpaper
    services.hyprpaper = {
      enable = true;

      settings = {
        preload = [ "/tmp/altered.png" ];
        wallpaper = [ ", /tmp/altered.png" ];
      };
    };
  };
}
