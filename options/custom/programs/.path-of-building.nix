{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.path-of-building;
in {
  options.custom.programs.path-of-building.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        xdg.desktopEntries.path-of-building = {
          name = "Path of Building";
          exec = "${pkgs.path-of-building}/bin/pobfrontend";
        };
      }
    ];
  };
}
