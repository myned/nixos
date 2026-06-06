{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.foot;
in {
  options.custom.programs.foot.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://codeberg.org/dnkl/foot
        programs.foot = {
          enable = true;

          # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
          settings = {
            main.font = "${config.stylix.fonts.monospace.name}:size=12";
            scrollback.lines = 10000; # Default 1000

            # Solarized Dark
            # https://codeberg.org/dnkl/foot/src/branch/master/themes/solarized-dark
            # https://fishshell.com/docs/current/cmds/set_color.html
            colors = {
              background = "002b36";
              foreground = "839496";
              regular0 = "073642";
              regular1 = "dc322f";
              regular2 = "859900";
              regular3 = "b58900";
              regular4 = "268bd2";
              regular5 = "d33682";
              regular6 = "2aa198";
              regular7 = "eee8d5";
              bright0 = "002b36";
              bright1 = "cb4b16";
              bright2 = "586e75";
              bright3 = "657b83";
              bright4 = "839496";
              bright5 = "6c71c4";
              bright6 = "93a1a1";
              bright7 = "fdf6e3";
            };
          };
        };

        # https://nix-community.github.io/stylix/options/modules/foot.html
        stylix.targets.foot.enable = false;
      }
    ];
  };
}
