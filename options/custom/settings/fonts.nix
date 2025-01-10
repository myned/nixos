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
    emoji = mkOption {default = "Noto Color Emoji";};
    fallback = mkOption {default = "Unifont";};
    monospace = mkOption {default = "IosevkaTerm NFP SemiBold";};
    sans-serif = mkOption {default = "Outfit";};
    serif = mkOption {default = "Liberation Serif";};
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
          space-mono
          zed-mono
        ]
        ++ (with pkgs; [
          ### Sans Serif
          (google-fonts.override {
            fonts = [
              # Text
              "Jost"
              "Lexend"
              "Outfit"

              # Condensed
              "Oswald"

              # Pixel
              "Silkscreen"
            ];
          })

          ### Other
          # Microsoft
          corefonts
          vistafonts

          # Fallback
          unifont
        ]);

      #?? fc-list --brief | grep family: | sort
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
