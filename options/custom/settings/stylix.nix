{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.stylix;
  hm = config.home-manager.users.${config.custom.username};
in {
  imports = [inputs.stylix.nixosModules.stylix];

  options.custom.settings.stylix = {
    enable = mkEnableOption "stylix";
  };

  config = mkMerge [
    # https://github.com/nix-community/stylix/blob/master/stylix/home-manager-integration.nix
    {home-manager.sharedModules = [config.stylix.homeManagerIntegration.module];}

    (mkIf cfg.enable (let
      commonConfig = {
        enable = true;

        # BUG: Modules not guarded by enabled NixOS option, causing unnecessary builds
        # https://github.com/nix-community/stylix/issues/543
        autoEnable = false;

        # https://nix-community.github.io/stylix/configuration.html#color-scheme
        # https://github.com/tinted-theming/schemes
        # https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/solarized-dark.yaml
        base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-dark.yaml";

        # https://nix-community.github.io/stylix/configuration.html#overriding
        # https://github.com/SenchoPens/base16.nix
        override = {};

        # https://nix-community.github.io/stylix/options/platforms/nixos.html#stylixpolarity
        polarity = "dark";

        # https://nix-community.github.io/stylix/options/platforms/nixos.html#stylixcursor
        cursor = {
          # https://github.com/ful1e5/Google_Cursor
          name = "GoogleDot-Black";
          package = pkgs.google-cursor;
          size = 24;
        };

        # https://nix-community.github.io/stylix/options/platforms/nixos.html#stylixfontsemoji
        fonts = with config.custom.settings.fonts; {
          inherit emoji monospace sansSerif serif;

          # https://nix-community.github.io/stylix/options/platforms/nixos.html#stylixfontssizesapplications
          sizes = {
            applications = 12;
            desktop = 12;
            popups = 12;
            terminal = 14;
          };
        };

        targets = {
          gtk.enable = true; # https://nix-community.github.io/stylix/options/modules/gtk.html
          gtksourceview.enable = true; # https://nix-community.github.io/stylix/options/modules/gtksourceview.html

          # https://nix-community.github.io/stylix/options/modules/qt.html
          # qt = {
          #   enable = true;

          #   # TODO: Use adwaita when supported
          #   platform = mkForce "qtct";
          # };
        };
      };
    in {
      # https://nix-community.github.io/stylix/
      # https://nix-community.github.io/stylix/configuration.html
      stylix = recursiveUpdate commonConfig {
        # HACK: Conditional imports prevent custom options from evaluating, so import and inherit manually
        homeManagerIntegration.autoImport = false;
      };

      home-manager.sharedModules = [
        {
          # https://nix-community.github.io/stylix/options/platforms/home_manager.html
          stylix = recursiveUpdate commonConfig {
            # https://nix-community.github.io/stylix/options/platforms/home_manager.html#stylixiconthemedark
            iconTheme = {
              # BUG: GTK4 apps start slower with Papirus
              # https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/issues/3860
              # https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
              # https://github.com/vinceliuice/Tela-icon-theme
              enable = true;
              dark = "Tela-pink-dark";
              light = "Tela-pink-light";
              package = pkgs.tela-icon-theme;
            };

            #!! Accent colors are not the same globally, so override each target individually
            # https://github.com/danth/stylix/issues/402
            targets = {
              gtk = {
                flatpakSupport.enable = true;
                extraCss = readFile ./gtk/style.css;
              };
            };
          };

          # BUG: home.pointerCursor breaks XCURSOR_PATH for some child windows, so avoid ${} bashism
          # https://github.com/nix-community/home-manager/blob/59a4c43e9ba6db24698c112720a58a334117de83/modules/config/home-cursor.nix#L154
          home.sessionVariables = {
            XCURSOR_PATH = "$XCURSOR_PATH:${hm.home.profileDirectory}/share/icons";
          };
        }
      ];
    }))
  ];
}
