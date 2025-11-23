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
        name = sansSerif;
        size = 12;
      };

      cursorTheme = with config.custom.settings.icons.cursor; {
        inherit name size;
      };

      iconTheme = with config.custom.settings.icons.icon; {
        inherit name;
      };

      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };

      gtk3.extraCss = css;
      gtk4.extraCss = css;
    };
  };
}
