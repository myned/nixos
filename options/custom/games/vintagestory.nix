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
        imports = [inputs.vintagestory-nix.homeModules.vs-launcher];

        # https://github.com/XurxoMF/vs-launcher
        programs.vs-launcher = {
          enable = true;
          settings.gameVersions = with pkgs.vintagestoryPackages; [v1-21-6];
        };
      }
    ];
  };
}
