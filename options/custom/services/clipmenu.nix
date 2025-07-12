{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.clipmenu;
in {
  options.custom.services.clipmenu = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/cdown/clipmenu
      services.clipmenu.enable = true;
    };
  };
}
