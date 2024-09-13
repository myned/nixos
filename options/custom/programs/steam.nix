{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.steam;
in {
  # https://wiki.nixos.org/wiki/Steam
  # https://store.steampowered.com
  options.custom.programs.steam = {
    enable = mkOption {default = false;};
    extest = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    programs.steam =
      {
        enable = true;
        extest.enable = cfg.extest; # Work around invisible cursor on Wayland
        extraCompatPackages = [pkgs.proton-ge-bin];

        gamescopeSession = {
          enable = true;
          # args = [
          #   "--backend sdl"
          #   "--fullscreen"
          # ];
        };
      }
      // optionalAttrs (versionAtLeast version "24.11") {protontricks.enable = true;};
  };
}
