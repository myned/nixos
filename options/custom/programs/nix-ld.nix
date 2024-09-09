{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.nix-ld;
in
{
  options.custom.programs.nix-ld.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/nix-ld
    programs.nix-ld.enable = true;
  };
}
