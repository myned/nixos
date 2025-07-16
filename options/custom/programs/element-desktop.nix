{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.element-desktop;
in {
  options.custom.programs.element-desktop.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/element-hq/element-desktop
    # HACK: Fix Electron not finding password store on unusual desktops, requires services.gnome.gnome-keyring
    nixpkgs.overlays = [
      (final: prev: {
        element-desktop = prev.element-desktop.override {
          commandLineArgs = "--password-store=gnome-libsecret";
        };
      })
    ];

    home-manager.users.${config.custom.username} = {
      # Custom themes
      # https://github.com/aaronraimist/element-themes
      xdg.configFile."Element/config.json".text = ''
        {
          "show_labs_settings": true,
          "setting_defaults": {
            "custom_themes": [
              {
                "name": "Solarized",
                "is_dark": true,
                "colors": {
                  "accent-color": "#b58900",
                  "primary-color": "#268bd2",
                  "reaction-row-button-selected-bg-color": "#268bd2",
                  "roomlist-background-color": "#073642",
                  "roomlist-highlights-color": "#002b36",
                  "roomlist-text-color": "#93a1a1",
                  "roomlist-text-secondary-color": "#586e75",
                  "secondary-content": "#93a1a1",
                  "sidebar-color": "#002b36",
                  "tertiary-content": "#586e75",
                  "timeline-background-color": "#073642",
                  "timeline-highlights-color": "#002b36",
                  "timeline-text-color": "#fdf6e3",
                  "timeline-text-secondary-color": "#93a1a1",
                  "warning-color": "#dc322f"
                }
              }
            ]
          }
        }
      '';
    };
  };
}
