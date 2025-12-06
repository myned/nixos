{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.ags;
in {
  options.custom.programs.ags.enable = mkOption {default = false;};

  config = mkMerge [
    {home-manager.sharedModules = [inputs.ags.homeManagerModules.default];}

    (mkIf cfg.enable {
      home-manager.sharedModules = [
        {
          # https://aylur.github.io/ags-docs
          # https://github.com/Aylur/ags
          programs.ags = {
            enable = true;
            configDir = ./.;
          };
        }
      ];
    })
  ];
}
