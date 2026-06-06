{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.cliphist;
in {
  options.custom.services.cliphist.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/sentriz/cliphist
        services.cliphist.enable = true;
      }
    ];
  };
}
