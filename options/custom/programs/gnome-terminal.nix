{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.gnome-terminal;
in
{
  options.custom.programs.gnome-terminal.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://gitlab.gnome.org/GNOME/gnome-terminal
    programs.gnome-terminal = {
      enable = true;

      profile."8856406f-96d1-4284-8428-2329d2458b55" = {
        default = true;
        visibleName = "Master"; # Profile name
        scrollOnOutput = false;
        showScrollbar = false;

        colors = {
          foregroundColor = "rgb(131,148,150)";
          backgroundColor = "rgb(0,43,54)";
          palette = [
            "rgb(7,54,66)"
            "rgb(220,50,47)"
            "rgb(133,153,0)"
            "rgb(181,137,0)"
            "rgb(38,139,210)"
            "rgb(211,54,130)"
            "rgb(42,161,152)"
            "rgb(238,232,213)"
            "rgb(0,43,54)"
            "rgb(203,75,22)"
            "rgb(88,110,117)"
            "rgb(101,123,131)"
            "rgb(131,148,150)"
            "rgb(108,113,196)"
            "rgb(147,161,161)"
            "rgb(253,246,227)"
          ];
        };
      };
    };
  };
}
