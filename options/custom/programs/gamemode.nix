{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.gamemode;
in
{
  options.custom.programs.gamemode.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/FeralInteractive/gamemode
    programs.gamemode.enable = true;
  };
}
