{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.logseq;
in {
  options.custom.programs.logseq.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    #!! Synced imperative configuration
    home.file.".logseq/" = {
      force = true;
      source = config.home-manager.users.${config.custom.username}.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/common/config/logseq/";
    };
  };
}
