{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.gtk;
in {
  options.custom.settings.gtk.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    gtk = let
      css = ''
        * {
          font-weight: ${config.custom.settings.fonts.weight};
        }

        ${readFile ./style.css}
      '';
    in {
      enable = true;

      font = with config.custom.settings.fonts; {
        name = sans-serif;
        size = 14;
      };

      cursorTheme = with config.custom.settings.icons.cursor; {
        inherit name package size;
      };

      iconTheme = with config.custom.settings.icons.icon; {
        inherit name package;
      };

      theme = {
        name = "adw-gtk3-dark";

        # BUG: Forces theme on GTK 4
        # https://github.com/nix-community/home-manager/issues/5133
        #// package = pkgs.adw-gtk3;
      };

      gtk3 = {
        extraCss = css;
      };

      gtk4 = {
        #// extraConfig.gtk-hint-font-metrics = 1; # Fix blurry fonts
        extraCss = css;
      };
    };
  };
}
