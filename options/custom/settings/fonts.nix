{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.fonts;
in {
  options.custom.settings.fonts.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      enableDefaultPackages = true; # Fallback fonts

      packages = with pkgs; [
        # Monospace
        (nerdfonts.override {fonts = ["Iosevka"];})

        # Sans Serif
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

        # Microsoft
        corefonts
      ];

      #?? fc-list --brief | grep family: | sort
      fontconfig.defaultFonts = {
        emoji = [config.custom.font.emoji];
        monospace = [config.custom.font.monospace];
        sansSerif = [config.custom.font.sans-serif];
        serif = [config.custom.font.serif];
      };
    };

    home-manager.users.${config.custom.username}.fonts.fontconfig.defaultFonts =
      config.fonts.fontconfig.defaultFonts;
  };
}
