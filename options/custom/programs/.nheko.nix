{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nheko;
in {
  options.custom.programs.nheko.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/Nheko-Reborn/nheko
        programs.nheko.enable = true;
      }
    ];
  };
}
