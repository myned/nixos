{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.easyeffects;
in
{
  options.custom.services.easyeffects.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/wwmm/easyeffects
    # systemctl --user start easyeffects.service
    services.easyeffects.enable = true;

    ### PRESETS ###
    # https://github.com/Digitalone1/EasyEffects-Presets
    home.file = with config.home-manager.users.${config.custom.username}.lib.file; {
      ".config/easyeffects/input".source = mkOutOfStoreSymlink "/home/${config.custom.username}/SYNC/linux/config/easyeffects/input";
      ".config/easyeffects/output".source = mkOutOfStoreSymlink "/home/${config.custom.username}/SYNC/linux/config/easyeffects/output";
    };
  };
}
