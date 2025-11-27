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
    enable = mkEnableOption "librewolf";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://librewolf.net/
      # https://codeberg.org/librewolf
      programs.librewolf = mkMerge [
        (import ./.common.nix {
          inherit config inputs lib pkgs;
          theme = true;
        })

        {
          enable = true;
        }
      ];

      home.file = {
        ".librewolf/profiles.ini".force = true;
      };

      # https://nix-community.github.io/stylix/options/modules/firefox.html
      stylix.targets.librewolf = {
        enable = true;
        firefoxGnomeTheme.enable = true; # https://github.com/rafaelmardojai/firefox-gnome-theme
        profileNames = ["default" "work"];
      };
    };
  };
}
