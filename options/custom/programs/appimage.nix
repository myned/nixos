{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.appimage;
in {
  options.custom.programs.appimage.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Appimage
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    environment.systemPackages = [pkgs.gearlever];

    home-manager.sharedModules = [
      {
        home.sessionPath = ["$HOME/AppImages"];
      }
    ];
  };
}
