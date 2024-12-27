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
    home.pointerCursor = {
      gtk.enable = true; # Propagate attributes to gtk.cursorTheme
      size = 24;
      name = "GoogleDot-Black";
      package = pkgs.google-cursor;
    };

    gtk = let
      css = readFile ./style.css;
    in {
      enable = true;
      gtk3.extraCss = css;

      gtk4 = {
        extraConfig.gtk-hint-font-metrics = 1; # Fix blurry fonts
        extraCss = css;
      };

      font = {
        name = config.custom.font.sans-serif;
        size = 12;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "adw-gtk3-dark";

        # BUG: Forces theme on GTK 4
        # https://github.com/nix-community/home-manager/issues/5133
        #// package = pkgs.adw-gtk3;
      };
    };
  };
}
