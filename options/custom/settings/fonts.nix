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
    sans-serif = mkOption {default = "Afacad";};
    serif = mkOption {default = "Lora";};
    weight = mkOption {default = "500";};
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      enableDefaultPackages = true; # Fallback fonts

      packages = with pkgs.nerd-fonts;
        [
          ### Monospace
          # https://www.nerdfonts.com/#home
          #?? kitten choose-fonts
          departure-mono
          gohufont
          iosevka-term
          iosevka-term-slab
          jetbrains-mono
          shure-tech-mono
          space-mono
          zed-mono
        ]
        ++ (with pkgs; [
          (google-fonts.override {
            fonts = [
              ### Sans Serif
              # Text
              "Afacad"
              "Outfit"
              "Urbanist"

              # Condensed
              "Oswald"

              # Pixel
              "Geo"
              "Silkscreen"

              ### Serif
              "Lora"
            ];
          })

          ### Emoji
          noto-fonts-emoji-blob-bin

          ### Other
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
