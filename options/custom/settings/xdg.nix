{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.xdg;
  hm = config.home-manager.users.${config.custom.username};

  #?? ls /run/current-system/sw/share/applications
  #?? ls /etc/profiles/per-user/myned/share/applications
  apostrophe = "org.gnome.gitlab.somas.Apostrophe.desktop";
  clapper = "com.github.rafostar.Clapper.desktop";
  decibels = "org.gnome.Decibels.desktop";
  file-roller = "org.gnome.File Roller.desktop";
  font-viewer = "org.gnome.font-viewer.desktop";
  gnome-text-editor = "org.gnome.TextEditor.desktop";
  inkscape = "org.inkscape.Inkscape.desktop";
  libreoffice = "base.desktop";
  loupe = "org.gnome.Loupe.desktop";
  nautilus = "org.gnome.Nautilus.desktop";
  onlyoffice = "onlyoffice-desktopeditors.desktop";
  papers = "org.gnome.Papers.desktop";
  showtime = "org.gnome.Showtime.desktop";
in {
  options.custom.settings.xdg = {
    enable = mkEnableOption "xdg";
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/XDG_Desktop_Portal
    xdg.portal = {
      enable = true;

      # Use portal for xdg-open
      # https://github.com/NixOS/nixpkgs/issues/160923
      # BUG: Window activation fails on niri
      #// xdgOpenUsePortal = true;
    };

    home-manager.sharedModules = [
      {
        xdg = {
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
              "application/msword" = libreoffice;
              "application/octet-stream" = "";
              "application/pdf" = papers;
              "application/rtf" = libreoffice;
              "application/schema+json" = gnome-text-editor;
              "application/sql" = gnome-text-editor;
              "application/toml" = gnome-text-editor;
              "application/vnd.adobe.flash.movie" = showtime;
              "application/vnd.apple.keynote" = gnome-text-editor;
              "application/vnd.ms-excel.sheet.macroEnabled.12" = libreoffice;
              "application/vnd.ms-excel" = libreoffice;
              "application/vnd.ms-powerpoint" = libreoffice;
              "application/vnd.ms-visio.drawing.main+xml" = gnome-text-editor;
              "application/vnd.oasis.opendocument.formula-template" = libreoffice;
              "application/vnd.oasis.opendocument.graphics" = libreoffice;
              "application/vnd.oasis.opendocument.spreadsheet" = libreoffice;
              "application/vnd.oasis.opendocument.text" = libreoffice;
              "application/vnd.openxmlformats-officedocument.presentationml.presentation" = libreoffice;
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = libreoffice;
              "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = libreoffice;
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
              "application/x-wine-extension-ini" = gnome-text-editor;
              "application/x-zerosize" = gnome-text-editor;
              "application/xhtml_xml" = gnome-text-editor;
              "application/xhtml+xml" = gnome-text-editor;
              "application/xml" = gnome-text-editor;
              "application/yaml" = gnome-text-editor;
              "application/zip" = file-roller;
              "audio/aac" = decibels;
              "audio/flac" = decibels;
              "audio/midi" = decibels;
              "audio/mpeg" = decibels;
              "audio/ogg" = decibels;
              "audio/opus" = decibels;
              "audio/vnd.wave" = decibels;
              "audio/vorbis" = decibels;
              "audio/x-mod" = gnome-text-editor;
              "font/ttf" = font-viewer;
              "font/woff2" = font-viewer;
              "image/bmp" = loupe;
              "image/gif" = loupe;
              "image/heif" = loupe;
              "image/jpeg" = loupe;
              "image/png" = loupe;
              "image/svg+xml" = inkscape;
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
              "video/mp4" = showtime;
              "video/x-matroska" = showtime;
              "x-scheme-handler/http" = config.custom.browser.desktop;
              "x-scheme-handler/https" = config.custom.browser.desktop;
            };
          };

          # https://gitlab.freedesktop.org/xdg/xdg-specs/-/merge_requests/46
          terminal-exec = {
            enable = true;
            settings.default = [config.custom.terminal.desktop];
          };

          userDirs = {
            enable = true;
            createDirectories = true;
            templates = "${config.custom.syncDir}/linux/config/templates";

            extraConfig = {
              XDG_GAMES_DIR = "${hm.home.homeDirectory}/Games";
              XDG_SCREENSHOTS_DIR = "${hm.xdg.userDirs.pictures}/Screenshots";
            };
          };
        };
      }
    ];
  };
}
