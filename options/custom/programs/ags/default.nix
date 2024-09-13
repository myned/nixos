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

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    imports = [inputs.ags.homeManagerModules.default];

    # https://aylur.github.io/ags-docs
    # https://github.com/Aylur/ags
    programs.ags = {
      enable = true;
      configDir = ./.;
    };
  };
}
