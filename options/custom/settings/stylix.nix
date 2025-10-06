{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.stylix;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.settings.stylix = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://stylix.danth.me/
    # https://stylix.danth.me/configuration.html
    stylix = {
      enable = true;

      # BUG: Modules not guarded by enabled NixOS option, causing unnecessary builds
      # https://github.com/nix-community/stylix/issues/543
      autoEnable = false;

      # https://stylix.danth.me/configuration.html#color-scheme
      # https://github.com/tinted-theming/schemes
      # https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/solarized-dark.yaml
      base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-dark.yaml";

      # https://stylix.danth.me/configuration.html#overriding
      # https://github.com/SenchoPens/base16.nix
      override = {};

      # https://stylix.danth.me/options/platforms/nixos.html#stylixpolarity
      polarity = "dark";

      # https://stylix.danth.me/options/platforms/nixos.html#stylixcursor
      cursor = {
        # https://github.com/ful1e5/Google_Cursor
        name = "GoogleDot-Black";
        package = pkgs.google-cursor;
        size = 24;
      };

      # https://stylix.danth.me/options/platforms/nixos.html#stylixfontsemoji
      fonts = with config.custom.settings.fonts; {
        inherit emoji monospace sansSerif serif;

        # https://stylix.danth.me/options/platforms/nixos.html#stylixfontssizesapplications
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
        qt = {
          enable = true;

          # TODO: Use adwaita when supported
          platform = mkForce "qtct";
        };
      };
    };

    home-manager.users.${config.custom.username} = {
      # https://stylix.danth.me/options/platforms/home_manager.html
      stylix = {
        # https://stylix.danth.me/options/platforms/home_manager.html#stylixiconthemedark
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
        targets = with config.stylix.targets; {
          inherit gtksourceview qt;

          gtk =
            gtk
            // {
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
    };
  };
}
