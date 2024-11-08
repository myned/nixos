{
  config,
  lib,
  ...
}:
with lib; let
  apostrophe = "org.gnome.gitlab.somas.Apostrophe.desktop";
  clapper = "com.github.rafostar.Clapper.desktop";
  decibels = "org.gnome.Decibels.desktop";
  file-roller = "org.gnome.File Roller.desktop";
  firefox-esr = "firefox-esr.desktop";
  font-viewer = "org.gnome.font-viewer.desktop";
  gnome-text-editor = "org.gnome.TextEditor.desktop";
  loupe = "org.gnome.Loupe.desktop";
  nautilus = "org.gnome.Nautilus.desktop";
  onlyoffice = "onlyoffice-desktopeditors.desktop";
  papers = "org.gnome.Papers.desktop";

  cfg = config.custom.settings.xdg;
in {
  options.custom.settings.xdg.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/XDG_Desktop_Portal
    xdg.portal = {
      enable = true;

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
          "application/epub+zip" = papers;
          "application/gzip" = file-roller;
          "application/java-archive" = gnome-text-editor;
          "application/json" = gnome-text-editor;
          "application/octet-stream" = "";
          "application/pdf" = papers;
          "application/rtf" = onlyoffice;
          "application/schema+json" = gnome-text-editor;
          "application/sql" = gnome-text-editor;
          "application/toml" = gnome-text-editor;
          "application/vnd.adobe.flash.movie" = clapper;
          "application/vnd.ms-excel.sheet.macroEnabled.12" = onlyoffice;
          "application/vnd.ms-excel" = onlyoffice;
          "application/vnd.ms-powerpoint" = onlyoffice;
          "application/vnd.ms-visio.drawing.main+xml" = gnome-text-editor;
          "application/vnd.oasis.opendocument.formula-template" = onlyoffice;
          "application/vnd.oasis.opendocument.graphics" = onlyoffice;
          "application/vnd.oasis.opendocument.spreadsheet" = onlyoffice;
          "application/vnd.oasis.opendocument.text" = onlyoffice;
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = onlyoffice;
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = onlyoffice;
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = onlyoffice;
          "application/vnd.sqlite3" = gnome-text-editor;
          "application/vnd.visio" = gnome-text-editor;
          "application/x-asar" = gnome-text-editor;
          "application/x-bat" = gnome-text-editor;
          "application/x-compressed-tar" = file-roller;
          "application/x-designer" = gnome-text-editor;
          "application/x-desktop" = gnome-text-editor;
          "application/x-etherpeek" = gnome-text-editor;
          "application/x-font-bdf" = font-viewer;
          "application/x-font-pcf" = font-viewer;
          "application/x-gz-font-linux-psf" = font-viewer;
          "application/x-mobipocket-ebook" = papers;
          "application/x-mozilla-bookmarks" = gnome-text-editor;
          "application/x-php" = gnome-text-editor;
          "application/x-powershell" = gnome-text-editor;
          "application/x-shellscript" = gnome-text-editor;
          "application/x-trash" = gnome-text-editor;
          "application/x-xpinstall" = gnome-text-editor;
          "application/xhtml_xml" = gnome-text-editor;
          "application/xhtml+xml" = gnome-text-editor;
          "application/xml" = gnome-text-editor;
          "application/yaml" = gnome-text-editor;
          "application/zip" = file-roller;
          "audio/midi" = decibels;
          "audio/mpeg" = decibels;
          "audio/vnd.wave" = decibels;
          "audio/x-mod" = gnome-text-editor;
          "font/ttf" = font-viewer;
          "font/woff2" = font-viewer;
          "image/bmp" = loupe;
          "image/gif" = loupe;
          "image/heif" = loupe;
          "image/jpeg" = loupe;
          "image/png" = loupe;
          "image/svg+xml" = loupe;
          "image/tiff" = loupe;
          "image/vnd.microsoft.icon" = loupe;
          "image/vnd.zbrush.pcx" = loupe;
          "image/webp" = loupe;
          "image/x-tga" = loupe;
          "image/x-xcf" = loupe;
          "inode/directory" = nautilus;
          "text/css" = gnome-text-editor;
          "text/csv" = gnome-text-editor;
          "text/html" = gnome-text-editor;
          "text/javascript" = gnome-text-editor;
          "text/markdown" = apostrophe;
          "text/plain" = gnome-text-editor;
          "text/tab-separated-values" = gnome-text-editor;
          "text/vnd.trolltech.linguist" = gnome-text-editor;
          "text/x-changelog" = gnome-text-editor;
          "text/x-common-lisp" = gnome-text-editor;
          "text/x-copying" = gnome-text-editor;
          "text/x-csrc" = gnome-text-editor;
          "text/x-dbus-service" = gnome-text-editor;
          "text/x-gettext-translation" = gnome-text-editor;
          "text/x-go" = gnome-text-editor;
          "text/x-gradle" = gnome-text-editor;
          "text/x-java" = gnome-text-editor;
          "text/x-log" = gnome-text-editor;
          "text/x-makefile" = gnome-text-editor;
          "text/x-meson" = gnome-text-editor;
          "text/x-python" = gnome-text-editor;
          "text/x-readme" = gnome-text-editor;
          "text/x-rst" = gnome-text-editor;
          "text/x-scss" = gnome-text-editor;
          "video/mp4" = clapper;
          "video/x-matroska" = clapper;
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
          XDG_SCREENSHOTS_DIR = "${config.home-manager.users.${config.custom.username}.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };
  };
}
