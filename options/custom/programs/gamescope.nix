{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.gamescope;
in
{
  options.custom.programs.gamescope.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/ValveSoftware/gamescope
    #!! Issues may arise depending on environment
    # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1523177264
    programs.gamescope = {
      enable = true;
      capSysNice = true; # Allow renice

      #!! Align default window size with Steam Deck resolution
      # args = [
      #   "--rt"
      #   "--output-width 1280"
      #   "--output-height 800"
      #   "--nested-refresh 60"
      # ];
    };
  };
}
