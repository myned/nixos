{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.firefox;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.firefox = {
    enable = mkOption {default = false;};
    profile = mkOption {default = "default";};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://www.mozilla.org/en-US/firefox/developer
      programs.firefox = mkMerge [
        (import ./.common.nix {
          inherit config inputs lib pkgs;
          profile = cfg.profile;
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
        # https://github.com/rafaelmardojai/firefox-gnome-theme
        firefoxGnomeTheme.enable = true;
        profileNames = [cfg.profile];
      };
    };
  };
}
