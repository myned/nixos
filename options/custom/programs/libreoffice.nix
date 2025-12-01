{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.libreoffice;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.libreoffice = {
    enable = mkEnableOption "libreoffice";

    package = mkOption {
      default = pkgs.libreoffice-fresh;
      type = types.package;
    };

    spellcheck = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://www.libreoffice.org
    # https://wiki.nixos.org/wiki/LibreOffice
    environment.systemPackages =
      [
        cfg.package
      ]
      ++ optionals cfg.spellcheck [
        pkgs.hunspell
      ];

    home-manager.sharedModules = [
      {
        #!! Options not available, files synced
        xdg.configFile = {
          "libreoffice/4/user" = {
            source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.syncDir}/linux/config/libreoffice/user";
            force = true;
          };
        };
      }
    ];
  };
}
