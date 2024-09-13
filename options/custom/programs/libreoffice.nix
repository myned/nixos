{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.libreoffice;
in {
  options.custom.programs.libreoffice = {
    enable = mkOption {default = false;};
    package = mkOption {default = pkgs.libreoffice-fresh;};
  };

  config = mkIf cfg.enable {
    # https://www.libreoffice.org
    environment.systemPackages = [cfg.package];

    #!! Options not available, files synced
    home-manager.users.${config.custom.username}.home.file.".config/libreoffice/4/user".source =
      config.home-manager.users.${config.custom.username}.lib.file.mkOutOfStoreSymlink
      "/home/${config.custom.username}/SYNC/linux/config/libreoffice/user";
  };
}
