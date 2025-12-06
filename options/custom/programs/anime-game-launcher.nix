{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.anime-game-launcher;
in {
  imports = [inputs.aagl-gtk-on-nix.nixosModules.default];

  options.custom.programs.anime-game-launcher = {
    enable = mkOption {default = false;};
    genshin-impact = mkOption {default = false;};
    honkai-impact = mkOption {default = false;};
    honkai-star-rail = mkOption {default = false;};
    universal = mkOption {default = false;};
    wuthering-waves = mkOption {default = false;};
    zenless-zone-zero = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/an-anime-team
    # https://github.com/ezKEa/aagl-gtk-on-nix
    #!! If error on first setup, clone components
    #?? git clone https://github.com/an-anime-team/components.git
    programs = {
      anime-game-launcher.enable = cfg.genshin-impact;
      anime-games-launcher.enable = cfg.universal;
      honkers-railway-launcher.enable = cfg.honkai-star-rail;
      honkers-launcher.enable = cfg.honkai-impact;
      sleepy-launcher.enable = cfg.zenless-zone-zero;
      wavey-launcher.enable = cfg.wuthering-waves;
    };
  };
}
