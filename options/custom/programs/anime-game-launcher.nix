{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.anime-game-launcher;
in
{
  options.custom.programs.anime-game-launcher.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://github.com/an-anime-team
    # https://github.com/ezKEa/aagl-gtk-on-nix
    #?? If error on first setup, clone components
    #?? git clone https://github.com/an-anime-team/components.git
    programs.honkers-railway-launcher.enable = true;
  };
}
