{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.playerctld;
in {
  options.custom.services.playerctld.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/altdesktop/playerctl
    services.playerctld.enable = true;
  };
}
