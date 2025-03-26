{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.mosh;
in {
  options.custom.programs.mosh = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://mosh.org/
    # https://github.com/mobile-shell/mosh
    # https://wiki.nixos.org/wiki/Mosh
    programs.mosh.enable = true; # !! Opens UDP ports 60000-61000

    environment.shellAliases = {
      mosh = "mosh --predict=always --predict-overwrite";
    };
  };
}
