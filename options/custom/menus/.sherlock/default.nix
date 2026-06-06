{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.menus.sherlock;
in {
  options.custom.menus.sherlock = {
    enable = mkEnableOption "sherlock";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/Skxxtz/sherlock
        programs.sherlock = {
          enable = true;
          systemd.enable = true;

          # https://github.com/Skxxtz/sherlock/blob/main/docs/config.md
          settings = {
          };

          # https://github.com/Skxxtz/sherlock/tree/main/themes
          style = readFile ./custom.css;

          # https://github.com/Skxxtz/sherlock/blob/main/docs/launchers.md
          #// launchers = {};

          # https://github.com/Skxxtz/sherlock/blob/main/docs/sherlockignore.md
          #// ignore = "";

          # https://github.com/Skxxtz/sherlock/blob/main/docs/aliases.md
          #// aliases = {};
        };
      }
    ];
  };
}
