{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.settings.gtk;
in
{
  options.custom.settings.gtk.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    home.pointerCursor = {
      gtk.enable = true; # Propagate attributes to gtk.cursorTheme
      size = 24;
      name = "GoogleDot-Black";
      package = pkgs.google-cursor;
    };

    gtk = {
      enable = true;
      gtk3.extraCss = builtins.readFile ./style.css;

      gtk4 = {
        extraConfig.gtk-hint-font-metrics = 1; # Fix blurry fonts
        extraCss = builtins.readFile ./style.css;
      };

      font = {
        name = "sans-serif";
        size = 12;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "adw-gtk3-dark";
        #// package = pkgs.adw-gtk3;
      };
    };
  };
}
