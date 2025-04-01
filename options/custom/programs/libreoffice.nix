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
    enable = mkOption {default = false;};
    package = mkOption {default = pkgs.libreoffice-fresh;};
  };

  config = mkIf cfg.enable {
    # https://www.libreoffice.org
    environment.systemPackages = [cfg.package];

    #!! Options not available, files synced
    home-manager.users.${config.custom.username} = {
      xdg.configFile."libreoffice/4/user" = {
        force = true;
        source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/linux/config/libreoffice/user";
      };
    };
  };
}
