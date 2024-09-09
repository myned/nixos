{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.programs.thunderbird;
in
{
  options.custom.programs.thunderbird.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Thunderbird
    # https://www.thunderbird.net
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird-115;

      profiles.default = {
        isDefault = true;
        userContent = ''@import "thunderbird-gnome-theme/theme/colors/dark.css";'';

        userChrome = ''
          @import "thunderbird-gnome-theme/theme/gnome-theme.css";

          :root {
            --gnome-accent: #6c71c4;
            --gnome-window-background: #002b36;
            --gnome-window-color: #93a1a1;
            --gnome-view-background: #073642;
            --gnome-sidebar-background: #002b36;
            --gnome-secondary-sidebar-background: #002b36;
            --gnome-menu-background: #073642;
            --gnome-headerbar-background: #002b36;
            --gnome-toolbar-icon-fill: #93a1a1;
            --gnome-tabbar-tab-hover-background: #073642;
            --gnome-tabbar-tab-active-background: #073642;
            --gnome-tabbar-tab-active-hover-background: #073642;

            --layout-background-3: #073642 !important;
          }

          :root:-moz-window-inactive {
            --gnome-inactive-entry-color: #586e75;
            --gnome-tabbar-tab-hover-background: #073642;
            --gnome-tabbar-tab-active-background: #073642;
          }
        '';

        settings = {
          # https://github.com/rafaelmardojai/thunderbird-gnome-theme?tab=readme-ov-file#required-thunderbird-preferences
          "svg.context-properties.content.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          "app.donation.eoy.version.viewed" = 5; # Disable donation banner
          "browser.display.document_color_use" = 2; # Override colors
          "browser.display.use_system_colors" = true;
          "mail.pane_config.dynamic" = 1; # Wide view
          "mailnews.message_display.disable_remote_image" = false;

          # Telemetry
          "datareporting.healthreport.uploadEnabled" = false;
          "dom.security.unexpected_system_load_telemetry_enabled" = false;
          "network.trr.confirmation_telemetry_enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.server" = "localhost";
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
        };
      };
    };

    accounts.email.accounts.${config.custom.username}.thunderbird.enable = true;

    # https://github.com/rafaelmardojai/thunderbird-gnome-theme
    home.file.".thunderbird/default/chrome/thunderbird-gnome-theme".source =
      inputs.thunderbird-gnome-theme;
  };
}
