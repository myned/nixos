{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.playerctld;
in {
  options.custom.services.playerctld.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/altdesktop/playerctl
        services.playerctld.enable = true;
      }
    ];
  };
}
