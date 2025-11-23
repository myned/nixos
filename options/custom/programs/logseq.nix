{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.logseq;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.logseq.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    #!! Synced imperative configuration
    home.file.".logseq/" = {
      force = true;
      source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.syncDir}/common/config/logseq/";
    };
  };
}
