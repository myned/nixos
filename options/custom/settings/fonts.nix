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
      ];

      #?? fc-list --brief | grep family: | sort
      fontconfig.defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["Iosevka NFP SemiBold"];
        sansSerif = ["Outfit"];
        serif = ["Liberation Serif"];
      };
    };

    home-manager.users.${config.custom.username}.fonts.fontconfig.defaultFonts =
      config.fonts.fontconfig.defaultFonts;
  };
}
