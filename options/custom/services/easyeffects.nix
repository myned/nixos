{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.easyeffects;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.services.easyeffects.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/wwmm/easyeffects
    # systemctl --user start easyeffects.service
    services.easyeffects.enable = true;

    ### PRESETS ###
    # https://github.com/Digitalone1/EasyEffects-Presets
    xdg.configFile = let
      sync = source: {
        source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/${source}";
        force = true;
      };
    in {
      #!! Imperative synced files
      "easyeffects/input" = sync "linux/config/easyeffects/input";
      "easyeffects/output" = sync "linux/config/easyeffects/output";
    };
  };
}
