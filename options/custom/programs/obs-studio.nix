{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.obs-studio;
in {
  options.custom.programs.obs-studio.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/obsproject/obs-studio
    programs.obs-studio.enable = true;

    xdg.configFile."obs-studio".source = config.home-manager.users.${config.custom.username}.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/common/config/obs-studio";
  };
}
