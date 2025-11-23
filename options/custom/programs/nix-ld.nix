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
    enable = mkOption {default = false;};
    nix-alien = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/nix-ld
    programs.nix-ld.enable = true;

    # https://github.com/thiagokokada/nix-alien
    #?? nix-alien -- BINARY
    environment.systemPackages = mkIf cfg.nix-alien [pkgs.nix-alien];

    # https://github.com/thiagokokada/nix-alien?tab=readme-ov-file#nixos-installation-with-flakes
    nixpkgs.overlays = mkIf cfg.nix-alien [inputs.nix-alien.overlays.default];
  };
}
