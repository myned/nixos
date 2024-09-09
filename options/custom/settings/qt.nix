{ config, lib, ... }:

with lib;

let
  cfg = config.custom.settings.qt;
in
{
  options.custom.settings.qt.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    qt = {
      enable = true;
      platformTheme.name = "gtk3";
    };
  };
}
