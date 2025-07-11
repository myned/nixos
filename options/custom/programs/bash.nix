{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.bash;
in {
  options.custom.programs.bash = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.bash = {
          enable = true;
        };
      }
    ];
  };
}
