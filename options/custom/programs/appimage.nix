{
  config,
  lib,
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
  };
}
