{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.fonts;
  hm = config.home-manager.users.${config.custom.username};

  rsync = getExe pkgs.rsync;
in {
  options.custom.settings.fonts = {
    enable = mkEnableOption "fonts";

    emoji = {
      name = mkOption {
        default = "Blobmoji";
        type = types.str;
      };

      package = mkOption {
        default = pkgs.noto-fonts-emoji-blob-bin;
        type = types.package;
      };
    };

    fallback = {
      name = mkOption {
        default = "Unifont";
        type = types.str;
      };

      package = mkOption {
        default = pkgs.unifont;
        type = types.package;
      };
    };

    monospace = {
      name = mkOption {
        default = "IosevkaTermSlab NFP Medium";
        type = types.str;
      };

      package = mkOption {
        default = pkgs.nerd-fonts.iosevka-term-slab;
        type = types.package;
      };
    };

    sansSerif = {
      name = mkOption {
        default = "Arvo";
        type = types.str;
      };

      package = mkOption {
        default = pkgs.google-fonts.override {fonts = [cfg.sansSerif.name];};
        type = types.package;
      };
    };

    serif = {
      name = mkOption {
        default = "Lora";
        type = types.str;
      };

      package = mkOption {
        default = pkgs.google-fonts.override {fonts = [cfg.serif.name];};
        type = types.package;
      };
    };

    weight = mkOption {
      default = "400";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      fontDir.enable = true; # /run/current-system/sw/share/X11/fonts

      fontconfig = {
        # https://wiki.nixos.org/wiki/Fonts#Noto_Color_Emoji_doesn't_render_on_Firefox
        #!! Causes some fonts like Calibri to render without antialiasing
        #// useEmbeddedBitmaps = true;

        #?? fc-list : family | sort
        defaultFonts = mkIf (!config.custom.settings.stylix.enable) {
          emoji = [cfg.emoji];
          monospace = [cfg.monospace];
          sansSerif = [cfg.sansSerif];
          serif = [cfg.serif];
        };
      };

      # BUG: Amount of installed fonts impacts pango load times, so only install necessary fonts
      # https://github.com/davatorium/rofi/issues/673 et al.
      packages =
        [
          # https://fonts.google.com/
          (pkgs.google-fonts.override {
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
        ]
        ++ (with pkgs.nerd-fonts; [
          # https://www.nerdfonts.com/#home
          # Monospace
          departure-mono
          gohufont
          iosevka-term
          iosevka-term-slab
          jetbrains-mono
          roboto-mono
          shure-tech-mono
          space-mono
          zed-mono
        ])
        ++ (with pkgs; [
          # Emoji
          noto-fonts-color-emoji
          noto-fonts-emoji-blob-bin

          # Microsoft
          carlito
          corefonts
          vista-fonts

          # Fallback
          unifont
        ]);
    };

    stylix.targets = {
      font-packages.enable = true;
      fontconfig.enable = true;
    };

    home-manager.users.${config.custom.username} = {
      # HACK: Some applications do not support fontconfig nor symlinks, so copy fonts to user directory
      # https://github.com/ONLYOFFICE/DocumentServer/issues/1859 et al.
      home.activation = {
        # BUG: rsync sets directory permissions too early
        # https://github.com/RsyncProject/rsync/issues/609
        copy-fonts = hm.lib.dag.entryAfter ["writeBoundary"] ''
          run ${rsync} --recursive --copy-links --times --delete \
            /run/current-system/sw/share/X11/fonts "${hm.home.sessionVariables.XDG_DATA_HOME}/"
        '';
      };

      stylix.targets = {
        font-packages.enable = true; # https://nix-community.github.io/stylix/options/modules/font-packages.html
        fontconfig.enable = true; # https://nix-community.github.io/stylix/options/modules/fontconfig.html
      };
    };
  };
}
