{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.easyeffects;
in {
  options.custom.services.easyeffects.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/wwmm/easyeffects
    # systemctl --user start easyeffects.service
    services.easyeffects.enable = true;

    ### PRESETS ###
    # https://github.com/Digitalone1/EasyEffects-Presets
    xdg.configFile = with config.home-manager.users.${config.custom.username}.lib.file; {
      "easyeffects/input" = {
        force = true;
        source = mkOutOfStoreSymlink "${config.custom.sync}/linux/config/easyeffects/input";
      };

      "easyeffects/output" = {
        force = true;
        source = mkOutOfStoreSymlink "${config.custom.sync}/linux/config/easyeffects/output";
      };
    };
  };
}
