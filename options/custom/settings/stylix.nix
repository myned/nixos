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
      autoEnable = true;

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
      fonts = {
        emoji = {
          name = "Blobmoji";
          package = pkgs.noto-fonts-emoji-blob-bin;
        };

        monospace = {
          name = "IosevkaTermSlab NFP Medium";
          package = pkgs.nerd-fonts.iosevka-term-slab;
        };

        sansSerif = {
          name = "Arvo";
          package = pkgs.google-fonts;
        };

        serif = {
          name = "Lora";
          package = pkgs.google-fonts;
        };

        # https://stylix.danth.me/options/platforms/nixos.html#stylixfontssizesapplications
        sizes = {
          applications = 12;
          desktop = 12;
          popups = 12;
          terminal = 14;
        };
      };
    };

    # Install packages to environment for imperative use
    fonts.packages = with pkgs.nerd-fonts;
      [
        # Monospace
        # https://www.nerdfonts.com/#home
        #?? kitten choose-fonts
        departure-mono
        gohufont
        iosevka-term
        iosevka-term-slab
        jetbrains-mono
        roboto-mono
        shure-tech-mono
        space-mono
        zed-mono
      ]
      ++ (with pkgs; [
        (google-fonts.override {
          fonts = [
            # Pixel
            "Geo"
            "Silkscreen"

            # Sans-serif
            "Josefin Sans"
            "Jost"
            "Lexend"
            "Outfit"
            "Roboto"
            "Roboto Flex"

            # Sans-serif condensed
            "Oswald"
            "Roboto Condensed"

            # Serif
            "Lora"
            "Roboto Serif"

            # Slab
            "Aleo"
            "Arvo"
            "Josefin Slab"
            "Roboto Slab"
            "Solway"
          ];
        })

        # Emoji
        noto-fonts-color-emoji
        noto-fonts-emoji-blob-bin

        # Microsoft
        corefonts
        vistafonts

        # Fallback
        unifont
      ]);

    home-manager.sharedModules = [
      {
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
          targets = {
            # TODO: Use gtksourceview target when merged
            # https://github.com/danth/stylix/issues/954
            gnome-text-editor.enable = false;

            gtk.extraCss = ''
              @define-color accent_color #d33682;
              @define-color accent_bg_color #d33682;
              @define-color window_bg_color #073642;
              @define-color borders #073642;
              @define-color unfocused_borders #073642;
            '';

            # BUG: Kvantum currently breaks Plasma 6, remove when fixed
            # https://github.com/danth/stylix/issues/835
            qt.enable = false;
          };
        };

        # BUG: home.pointerCursor breaks XCURSOR_PATH for some child windows, so avoid ${} bashism
        # https://github.com/nix-community/home-manager/blob/59a4c43e9ba6db24698c112720a58a334117de83/modules/config/home-cursor.nix#L154
        home.sessionVariables = {
          XCURSOR_PATH = "$XCURSOR_PATH:${hm.home.profileDirectory}/share/icons";
        };
      }
    ];
  };
}
