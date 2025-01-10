{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.ghostty;
in {
  options.custom.programs.ghostty = {
    enable = mkOption {default = false;};
    minimal = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.minimal [pkgs.ghostty]; # Terminfo

    home-manager.sharedModules = mkIf (!cfg.minimal) [
      {
        # https://ghostty.org/
        programs.ghostty = {
          enable = true;

          # https://ghostty.org/docs/config/reference
          settings = rec {
            adjust-cell-width = -1;

            # https://ghostty.org/docs/config/reference#adw-toolbar-style
            adw-toolbar-style = "flat";

            # https://ghostty.org/docs/config/reference#cursor-style-blink
            cursor-style-blink = false;

            # https://ghostty.org/docs/config/reference#font-family
            #?? ghostty +list-fonts
            #?? ghostty +show-face
            font-family = with config.custom.settings.fonts; [monospace fallback];
            font-family-bold = font-family;

            # https://ghostty.org/docs/config/reference#font-size
            font-size = 14;

            # https://ghostty.org/docs/config/reference#gtk-titlebar
            gtk-titlebar = false;

            # https://ghostty.org/docs/config/reference#mouse-hide-while-typing
            mouse-hide-while-typing = true;

            # https://ghostty.org/docs/config/reference#shell-integration-features
            shell-integration-features = "no-cursor";

            # https://ghostty.org/docs/features/theme
            # https://ghostty.org/docs/config/reference#theme
            #?? ghostty +list-themes
            theme = "Builtin Solarized Dark";

            # https://ghostty.org/docs/config/reference#window-decoration
            window-decoration = false;

            # https://ghostty.org/docs/config/reference#window-new-tab-position
            window-new-tab-position = "end";

            # https://ghostty.org/docs/config/reference#window-padding-balance
            # BUG: Not always distributed equally
            # https://github.com/ghostty-org/ghostty/discussions/3941
            window-padding-balance = true;

            # https://ghostty.org/docs/config/reference#window-padding-x
            window-padding-x = 8;
            window-padding-y = 4;
          };
        };
      }
    ];
  };
}
