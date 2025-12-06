{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nix-index;
in {
  imports = [inputs.nix-index-database.nixosModules.nix-index];

  options.custom.programs.nix-index.enable = mkOption {default = false;};

  config = mkMerge [
    {home-manager.sharedModules = [inputs.nix-index-database.homeModules.nix-index];}

    (mkIf cfg.enable {
      # https://github.com/nix-community/nix-index
      # https://github.com/nix-community/nix-index-database
      #?? nix-index
      #?? nix-locate -p <package> <pattern>
      programs = {
        nix-index.enable = true;
        command-not-found.enable = false;
      };

      home-manager.sharedModules = [
        {
          programs.nix-index.enable = true;
        }
      ];
    })
  ];
}
