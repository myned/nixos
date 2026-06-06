{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.menus.anyrun;
in {
  options.custom.menus.anyrun.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/Kirottu/anyrun
        programs.anyrun = {
          enable = true;

          # https://github.com/Kirottu/anyrun/blob/master/nix/hm-module.nix
          config = {
            plugins = with inputs.anyrun.packages.${pkgs.system}; [
              applications
              dictionary
              #// kidex # File search
              #// randr # Hyprland only
              rink # Calculator
              shell
              #// stdin # Entries from input, aka dmenu
              symbols
              translate
              websearch
            ];

            closeOnClick = true; # Close when clicking outside the runner
            hidePluginInfo = true; # Disable plugin sections
            y.fraction = 0.3; # Relative position from the top
          };

          # https://github.com/Kirottu/anyrun/blob/master/anyrun/res/style.css
          extraCss = ''
            *:not(separator) {
              margin: 2px;
              border-radius: 20px;
            }

            *:focus { outline: none; }

            #window {
              font: 16px ${config.stylix.fonts.monospace.name};
              background: none;
            }

            #entry {
              margin: 8px;
              padding: 4px 12px;
              font-size: 24px;
            }
          '';
        };
      }
    ];
  };
}
