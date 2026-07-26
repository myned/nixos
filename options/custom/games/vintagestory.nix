{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.games.vintagestory;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.games.vintagestory = {
    enable = mkEnableOption "vintagestory";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [inputs.vintagestory-nix.overlays.default];

    home-manager.sharedModules = [
      {
        # https://github.com/PierreBorine/vintagestory-nix/tree/master/tools
        imports = [inputs.vintagestory-nix.homeModules.mvl];

        # https://github.com/scgm0/MVL
        programs.mvl = {
          enable = true;
          settings.gameVersions = [inputs.vintagestory-nix.packages.${pkgs.system}.v1-22-0];
        };
      }
    ];
  };
}
