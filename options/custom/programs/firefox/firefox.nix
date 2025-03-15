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
    enable = mkOption {default = false;};
    profile = mkOption {default = "default";};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://www.mozilla.org/en-US/firefox/developer
        programs.firefox = mkMerge [
          (import ./.common.nix {
            inherit config inputs lib pkgs;
            profile = cfg.profile;
            theme = true;
          })

          {
            enable = true;
            #// package = pkgs.firefox-devedition-bin;
          }
        ];

        # https://stylix.danth.me/options/modules/firefox.html
        stylix.targets.firefox = {
          # BUG: Tab groups not yet supported
          # https://github.com/rafaelmardojai/firefox-gnome-theme/issues/901
          # https://github.com/rafaelmardojai/firefox-gnome-theme
          firefoxGnomeTheme.enable = true;
          profileNames = [cfg.profile];
        };
      }
    ];
  };
}
