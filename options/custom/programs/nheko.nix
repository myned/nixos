{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nheko;
in {
  options.custom.programs.nheko.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/Nheko-Reborn/nheko
    programs.nheko.enable = true;
  };
}
