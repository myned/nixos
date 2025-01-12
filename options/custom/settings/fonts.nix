{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.fonts;
in {
  options.custom.settings.fonts = {
    enable = mkOption {default = false;};
    emoji = mkOption {default = "Blobmoji";};
    fallback = mkOption {default = "Unifont";};
    monospace = mkOption {default = "IosevkaTermSlab NFP Medium";};
    sans-serif = mkOption {default = "Arvo";};
    serif = mkOption {default = "Lora";};
    weight = mkOption {default = "400";};
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      enableDefaultPackages = true; # Fallback fonts

      packages = with pkgs.nerd-fonts;
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

      #?? fc-list : family | sort
      fontconfig.defaultFonts = {
        emoji = [cfg.emoji];
        monospace = [cfg.monospace];
        sansSerif = [cfg.sans-serif];
        serif = [cfg.serif];
      };
    };

    home-manager.users.${config.custom.username}.fonts.fontconfig.defaultFonts = config.fonts.fontconfig.defaultFonts;
  };
}
