{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.ags;
in {
  options.custom.programs.ags.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        imports = [inputs.ags.homeManagerModules.default];

        # https://aylur.github.io/ags-docs
        # https://github.com/Aylur/ags
        programs.ags = {
          enable = true;
          configDir = ./.;
        };
      }
    ];
  };
}
