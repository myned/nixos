{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.nix-ld;
in {
  options.custom.programs.nix-ld = {
    enable = mkEnableOption "nix-ld";
  };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/nix-ld
    programs.nix-ld = {
      enable = true;
      #// libraries = with pkgs; [];
    };

    # https://github.com/thiagokokada/nix-alien
    #?? nix-alien -- BINARY
    nixpkgs.overlays = [inputs.nix-alien.overlays.default];
    environment.systemPackages = [pkgs.nix-alien];
  };
}
