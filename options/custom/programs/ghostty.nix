{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.ghostty;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.ghostty = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://ghostty.org/
        programs.ghostty = {
          enable = true;

          # https://ghostty.org/docs/config/reference
          settings = {
          };
        };
      }
    ];
  };
}
