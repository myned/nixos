{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.remmina;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.remmina.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      #!! Imperative configuration
      xdg.configFile."remmina/remmina.pref" = {
        force = true;
        source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/linux/config/remmina/remmina.pref";
      };
    };
  };
}
