{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  evince = "org.gnome.Evince.desktop";
  firefox-esr =
    config.home-manager.users.${config.custom.username}.programs.firefox.package.desktopItem.name;
  gnome-text-editor = "org.gnome.TextEditor.desktop";
  loupe = "org.gnome.Loupe.desktop";
  nautilus = "org.gnome.Nautilus.desktop";

  cfg = config.custom.settings.xdg;
in
{
  options.custom.settings.xdg.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/XDG_Desktop_Portal
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [
        "hyprland"
        "gtk"
      ]; # Prefer hyprland over gtk portal

      # Use portal for xdg-open
      # https://github.com/NixOS/nixpkgs/issues/160923
      xdgOpenUsePortal = true;
    };

    home-manager.users.${config.custom.username}.xdg = {
      configFile."mimeapps.list".force = true;

      mimeApps = {
        enable = true;

        # https://www.iana.org/assignments/media-types/media-types.xhtml
        #?? xdg-mime query <default|filetype>
        defaultApplications = {
          "application/json" = gnome-text-editor;
          "application/pdf" = evince;
          "application/xhtml+xml" = gnome-text-editor;
          "application/xhtml_xml" = gnome-text-editor;
          "application/xml" = gnome-text-editor;
          "image/jpeg" = loupe;
          "image/png" = loupe;
          "inode/directory" = nautilus;
          "text/html" = gnome-text-editor;
          "text/plain" = gnome-text-editor;
          "x-scheme-handler/http" = firefox-esr;
          "x-scheme-handler/https" = firefox-esr;
        };
      };

      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = null;
        templates = "/home/${config.custom.username}/SYNC/linux/config/templates";

        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${
            config.home-manager.users.${config.custom.username}.xdg.userDirs.pictures
          }/Screenshots";
        };
      };
    };
  };
}
