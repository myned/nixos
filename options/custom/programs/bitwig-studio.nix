{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.bitwig-studio;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.bitwig-studio = {
    enable = mkEnableOption "bitwig-studio";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.bitwig-studio];

    home-manager.sharedModules = [
      {
        home.file = {
          ".BitwigStudio/prefs" = {
            source = hm.lib.file.mkOutOfStoreSymlink "${hm.home.homeDirectory}/PACK/Bitwig/prefs";
            force = true;
          };
        };
      }
    ];
  };
}
