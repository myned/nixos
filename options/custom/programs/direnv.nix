{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.direnv;
in {
  options.custom.programs.direnv.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/direnv/direnv
    programs.direnv = {
      enable = true;
      loadInNixShell = false; # nix develop
      silent = true;
    };

    home-manager.users.${config.custom.username} = {
      programs.direnv = {
        enable = true;
        silent = true;
      };
    };
  };
}
