{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.icons;
in {
  options.custom.settings.icons = {
    enable = mkOption {default = false;};

    cursor = {
      # https://github.com/ful1e5/Google_Cursor
      name = mkOption {default = "GoogleDot-Black";};
      package = mkOption {default = pkgs.google-cursor;};
      size = mkOption {default = 24;};
    };

    icon = {
      # BUG: GTK4 apps start slower, use Papirus if fixed
      # https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/issues/3860
      # https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
      #// name = mkOption {default = "Papirus-Dark";};
      #// package = mkOption {default = pkgs.papirus-icon-theme;};

      name = mkOption {default = "Tela-pink-dark";};
      package = mkOption {default = pkgs.tela-icon-theme;};
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.cursor.package cfg.icon.package];

    # HACK: Copy home-manager implementation without setting XCURSOR_* environment variables
    home-manager.sharedModules = let
      # https://github.com/nix-community/home-manager/blob/59a4c43e9ba6db24698c112720a58a334117de83/modules/config/home-cursor.nix#L66C3-L77C8
      defaultIndexThemePackage = pkgs.writeTextFile {
        name = "index.theme";
        destination = "/share/icons/default/index.theme";

        text = ''
          [Icon Theme]
          Name=Default
          Comment=Default Cursor Theme
          Inherits=${cfg.cursor.name}
        '';
      };
    in [
      {
        # BUG: home.pointerCursor breaks XCURSOR_PATH for some child windows, so avoid that workaround
        # https://github.com/nix-community/home-manager/blob/59a4c43e9ba6db24698c112720a58a334117de83/modules/config/home-cursor.nix#L154
        home.sessionVariables = with cfg.cursor; {
          XCURSOR_SIZE = toString size;
          XCURSOR_THEME = name;
        };

        # https://github.com/nix-community/home-manager/blob/59a4c43e9ba6db24698c112720a58a334117de83/modules/config/home-cursor.nix#L161
        home.file = {
          ".icons/default/index.theme".source = "${defaultIndexThemePackage}/share/icons/default/index.theme";
          ".icons/${cfg.cursor.name}".source = "${cfg.cursor.package}/share/icons/${cfg.cursor.name}";
        };

        xdg.dataFile = {
          "icons/default/index.theme".source = "${defaultIndexThemePackage}/share/icons/default/index.theme";
          "icons/${cfg.cursor.name}".source = "${cfg.cursor.package}/share/icons/${cfg.cursor.name}";
        };
      }
    ];
  };
}
