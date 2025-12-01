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
    programs.direnv =
      {
        enable = true;
        loadInNixShell = false; # nix develop
      }
      // optionalAttrs (versionAtLeast version "24.11") {
        silent = true;
      };

    home-manager.sharedModules = [
      {
        programs.direnv =
          {
            enable = true;
          }
          // optionalAttrs (versionAtLeast version "24.11") {
            silent = true;
          };
      }
    ];
  };
}
