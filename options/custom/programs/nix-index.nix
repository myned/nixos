{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nix-index;
in {
  options.custom.programs.nix-index.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/nix-community/nix-index
    # https://github.com/nix-community/nix-index-database
    #?? nix-index
    #?? nix-locate -p <package> <pattern>
    programs = {
      nix-index.enable = true;
      command-not-found.enable = false;
    };

    home-manager.users.${config.custom.username}.programs.nix-index.enable = true;
  };
}
