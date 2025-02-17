{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.librewolf;
in {
  options.custom.programs.librewolf = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://librewolf.net/
        # https://codeberg.org/librewolf
        programs.librewolf = mkMerge [
          (import "${inputs.self}/modules/firefox.nix" {inherit config inputs lib pkgs;})

          {
            enable = true;
          }
        ];

        home.file = {
          ".librewolf/profiles.ini" = {
            force = true;
          };
        };
      }
    ];
  };
}
