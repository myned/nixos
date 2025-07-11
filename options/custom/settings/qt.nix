{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.qt;
in {
  options.custom.settings.qt.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    qt = {
      enable = true;
      style = "gtk2";
    };

    home-manager.users.${config.custom.username} = {
      qt = {
        enable = true;
        style.name = "gtk";
      };
    };
  };
}
