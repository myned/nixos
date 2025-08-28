{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.firefox;
in {
  options.custom.programs.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://www.mozilla.org/en-US/firefox/developer
      programs.firefox = mkMerge [
        (import ./.common.nix {
          inherit config inputs lib pkgs;
          telemetry = true;
          theme = true;
        })

        {
          enable = true;
          #// package = pkgs.firefox-devedition-bin;
        }
      ];

      home.file = {
        ".mozilla/firefox/profiles.ini".force = true;
      };

      # https://stylix.danth.me/options/modules/firefox.html
      stylix.targets.firefox = {
        enable = true;
        firefoxGnomeTheme.enable = true; # https://github.com/rafaelmardojai/firefox-gnome-theme
        profileNames = ["default" "work"];
      };
    };
  };
}
