{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nix-index;
in {
  imports = [inputs.nix-index-database.nixosModules.default];

  options.custom.programs.nix-index = {
    enable = mkEnableOption "nix-index";
  };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/nix-index
    # https://github.com/nix-community/nix-index-database
    #?? nix-index
    #?? nix-locate -p <package> <pattern>
    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true; # https://github.com/nix-community/comma
  };
}
