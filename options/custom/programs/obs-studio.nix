{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.obs-studio;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.obs-studio.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/obsproject/obs-studio
    programs.obs-studio.enable = true;

    xdg.configFile."obs-studio".source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.syncDir}/common/config/obs-studio";
  };
}
