{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.firefox;
in {
  options.custom.programs.firefox.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # TODO: Switch to librewolf when supported by module
    # https://github.com/nix-community/home-manager/pull/5128
    #!! Creates package derivation
    #?? config.home-manager.users.${config.custom.username}.programs.firefox.finalPackage
    # https://www.mozilla.org/en-US/firefox/developer
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-esr-128;

      # nativeMessagingHosts = with pkgs; [
      #   firefoxpwa
      #   gnome-browser-connector
      # ];

      #!! Prefer policy over profile
      #?? about:profiles
      profiles.default = {
        # Import CSS theme with solarized overrides
        # https://github.com/rafaelmardojai/firefox-gnome-theme/blob/master/theme/colors/dark.css
        userChrome = ''
          @import "firefox-gnome-theme/userChrome.css";

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
          }

          :root:-moz-window-inactive {
            --gnome-inactive-entry-color: #586e75;
            --gnome-tabbar-tab-hover-background: #073642;
            --gnome-tabbar-tab-active-background: #073642;
          }

          /* Center bookmarks */
          #PlacesToolbarItems {
            justify-content: center;
          }

          /* Disable bookmark folder icons */
          .bookmark-item[container] > .toolbarbutton-icon {
            display: none;
          }
        '';

        userContent = ''@import "firefox-gnome-theme/userContent.css";'';

        settings = {
          # https://github.com/rafaelmardojai/firefox-gnome-theme?tab=readme-ov-file#features
          "gnomeTheme.bookmarksToolbarUnderTabs" = true;
          "gnomeTheme.systemIcons" = true;

          "font.default.x-unicode" = config.custom.font.sans-serif;
          "font.default.x-western" = config.custom.font.sans-serif;
          "font.name-list.emoji" = config.custom.font.emoji; # System emoji
          "font.name.monospace.x-unicode" = config.custom.font.monospace;
          "font.name.monospace.x-western" = config.custom.font.monospace;
          "font.name.sans-serif.x-unicode" = config.custom.font.sans-serif;
          "font.name.sans-serif.x-western" = config.custom.font.sans-serif;
          "font.name.serif.x-unicode" = config.custom.font.sans-serif;
          "font.name.serif.x-western" = config.custom.font.sans-serif;
          "full-screen-api.ignore-widgets" = false; # Fake fullscreen
          "full-screen-api.warning.delay" = -1;
          "full-screen-api.warning.timeout" = 0;
          "middlemouse.paste" = false;
          "privacy.donottrackheader.enabled" = true;
          "privacy.fingerprintingProtection" = false;
          "privacy.globalprivacycontrol.enabled" = true;
          "svg.context-properties.content.enabled" = true; # Dark theme icons
        };
      };

      # https://mozilla.github.io/policy-templates
      policies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisableMasterPasswordCreation = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;

        DNSOverHTTPS = {
          Enabled = false;
          Locked = true;
        };

        DontCheckDefaultBrowser = true;

        # https://mozilla.github.io/policy-templates/#extensionsettings
        #?? https://addons.mozilla.org/en-US/firefox
        #?? about:support#addons
        ExtensionSettings = let
          extension = id: {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
            installation_mode = "normal_installed";
          };
        in
          mkMerge [
            (mkIf config.custom.minimal {
              "uBlock0@raymondhill.net" = extension "ublock-origin"; # uBlock Origin
            })

            (mkIf config.custom.full {
              "{d634138d-c276-4fc8-924b-40a0ea21d284}" = extension "1password-x-password-manager"; # 1Password: Password Manager
              #// "firefox@betterttv.net" = extension "betterttv"; # BetterTTV
              #// "{446900e4-71c2-419f-a6a7-df9c091e268b}" = extension "bitwarden-password-manager"; # Bitwarden
              #// "FirefoxColor@mozilla.com" = extension "firefox-color"; # Firefox Color
              #// "chrome-gnome-shell@gnome.org" = extension "gnome-shell-integration"; # GNOME Shell Integration
              #// "{248e6a49-f636-4c81-9899-a456eb6291a8}" = extension "ground-news-bias-checker"; # Ground News Bias Checker
              "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = extension "youtube-addon"; # ImprovedTube
              "7esoorv3@alefvanoon.anonaddy.me" = extension "libredirect"; # LibRedirect
              #// "firefoxpwa@filips.si" = extension "pwas-for-firefox"; # Progressive Web Apps for Firefox
              "select-after-closing-current@qw.linux-2g64.local" = extension "select-after-closing-current"; # Select After Closing Current
              "simple-tab-groups@drive4ik" = extension "simple-tab-groups"; # Simple Tab Groups
              "sponsorBlocker@ajay.app" = extension "sponsorblock"; # SponsorBlock
              "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = extension "styl-us"; # Stylus
              #// "{a0370179-acc3-452f-9530-246b6adb2768}" = extension "svelte-devtools"; # Svelte Devtools
              "uBlock0@raymondhill.net" = extension "ublock-origin"; # uBlock Origin
              "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}" = extension "user-agent-string-switcher"; # User-Agent Switcher and Manager
              #// "{c49b13b1-5dee-4345-925e-0c793377e3fa}" = extension "youtube-enhancer-vc"; # YouTube Enhancer
            })
          ];

        FirefoxHome = {
          Highlights = false;
          Pocket = false;
          Search = false;
          Snippets = false;
          SponsoredPocket = false;
          SponsoredTopSites = false;
          TopSites = false;
          Locked = true;
        };

        FirefoxSuggest = {
          ImproveSuggest = false;
          SponsoredSuggestions = false;
          WebSuggestions = false;
          Locked = true;
        };

        HardwareAcceleration = true;

        Homepage = {
          StartPage = "previous-session";
          Locked = true;
        };

        NetworkPrediction = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OverrideFirstRunPage = "";
        PasswordManagerEnabled = false;

        Permissions = {
          Autoplay.Default = "block-audio-video";
          Location.BlockNewRequests = true;
        };

        PictureInPicture = {
          Enabled = true;
          Locked = true;
        };

        PopupBlocking.Default = true;

        #!! Only certain preferences are supported via policies
        # https://mozilla.github.io/policy-templates/#preferences
        #?? about:config
        Preferences = let
          locked = value: {
            Value = value;
            Status = "locked";
          };
        in {
          "accessibility.browsewithcaret" = locked false;
          "accessibility.typeaheadfind" = locked false;
          "browser.aboutConfig.showWarning" = locked false;
          "browser.contentblocking.category" = locked "standard";
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = locked false;
          "browser.ctrlTab.sortByRecentlyUsed" = locked false;
          "browser.download.always_ask_before_handling_new_types" = locked false;
          "browser.download.useDownloadDir" = locked true;
          "browser.link.open_newwindow" = locked 3; # New tab
          "browser.link.open_newwindow.restriction" = locked 0; # Popups in new tab
          "browser.newtabpage.enabled" = locked true;
          "browser.preferences.defaultPerformanceSettings.enabled" = locked true;
          "browser.quitShortcut.disabled" = locked true;
          "browser.search.widget.inNavBar" = locked false;
          "browser.startup.homepage" = locked "about:home";
          "browser.startup.page" = locked 3; # Previous session
          "browser.tabs.closeTabByDblclick" = locked true;
          "browser.tabs.closeWindowWithLastTab" = locked false;
          "browser.tabs.insertAfterCurrent" = locked false;
          "browser.tabs.insertRelatedAfterCurrent" = locked false;
          "browser.tabs.loadInBackground" = locked true;
          "browser.tabs.warnOnClose" = locked false;
          "browser.tabs.warnOnCloseOtherTabs" = locked false;
          "browser.theme.dark-private-windows" = locked false;
          "browser.toolbars.bookmarks.showOtherBookmarks" = locked false;
          "browser.uidensity" = locked 0;
          "browser.warnOnQuitShortcut" = locked true;
          "dom.security.https_only_mode" = locked true;
          "extensions.formautofill.addresses.enabled" = locked false;
          "extensions.formautofill.creditCards.enabled" = locked false;
          "general.autoScroll" = locked false;
          "general.smoothScroll" = locked true;
          "layers.acceleration.force-enabled" = locked true;
          "layout.css.always_underline_links" = locked false;
          "layout.css.backdrop-filter.enabled" = locked true;
          "layout.spellcheckDefault" = locked 0; # Disabled
          "media.eme.enabled" = locked true; # DRM
          "media.ffmpeg.vaapi.enabled" = locked true;
          "media.hardwaremediakeys.enabled" = locked true;
          "media.hardware-video-decoding.enabled" = locked true;
          #// "media.rdd-process.enabled" = locked false; # RDD sandbox #!! Insecure
          "toolkit.legacyUserProfileCustomizations.stylesheets" = locked true;
          "ui.key.menuAccessKey" = locked 0; # Disable menu key
          "widget.gtk.overlay-scrollbars.enabled" = locked true;
          "widget.gtk.rounded-bottom-corners.enabled" = locked true;
        };

        SearchBar = "unified";

        # https://mozilla.github.io/policy-templates/#searchengines-this-policy-is-only-available-on-the-esr
        SearchEngines = {
          Default = "Duck"; # Default name cannot be removed

          Add = [
            {
              Name = "Amazon";
              Alias = "a";
              IconURL = "https://www.amazon.com/favicon.ico";
              URLTemplate = "https://www.amazon.com/s?k={searchTerms}";
            }

            {
              Name = "ArchWiki";
              Alias = "aw";
              IconURL = "https://wiki.archlinux.org/favicon.ico";
              URLTemplate = "https://wiki.archlinux.org/index.php?search={searchTerms}";
            }

            {
              Name = "Brave";
              Alias = "b";
              IconURL = "https://cdn.search.brave.com/serp/v2/_app/immutable/assets/favicon.c09fe1a1.ico";
              URLTemplate = "https://search.brave.com/search?q={searchTerms}";
            }

            {
              Name = "Docker Hub";
              Alias = "dh";
              IconURL = "https://hub.docker.com/favicon.ico";
              URLTemplate = "https://hub.docker.com/search?q={searchTerms}";
            }

            {
              Name = "Duck";
              Alias = "d";
              IconURL = "https://duckduckgo.com/favicon.ico";
              URLTemplate = "https://duckduckgo.com/?q={searchTerms}";
              SuggestURLTemplate = "https://duckduckgo.com/ac/?type=list&q={searchTerms}";
            }

            {
              Name = "e621";
              Alias = "e";
              IconURL = "https://e621.net/favicon.ico";
              URLTemplate = "https://e621.net/posts?tags={searchTerms}";
            }

            {
              Name = "Element Issues";
              Alias = "ei";
              IconURL = "https://github.com/favicon.ico";
              URLTemplate = "https://github.com/element-hq/element-web/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
            }

            {
              Name = "Flathub";
              Alias = "fh";
              IconURL = "https://flathub.org/favicon.png";
              URLTemplate = "https://flathub.org/apps/search?q={searchTerms}";
            }

            {
              Name = "GitHub";
              Alias = "gh";
              IconURL = "https://github.com/favicon.ico";
              URLTemplate = "https://github.com/search?q={searchTerms}";
            }

            {
              Name = "Google";
              Alias = "g";
              IconURL = "https://www.google.com/favicon.ico";
              URLTemplate = "https://www.google.com/search?q={searchTerms}";
            }

            {
              Name = "Home Manager Options";
              Alias = "ho";
              IconURL = "https://home-manager-options.extranix.com/images/favicon.png";
              URLTemplate = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
            }

            {
              Name = "Home Manager Issues";
              Alias = "hi";
              IconURL = "https://github.com/favicon.ico";
              URLTemplate = "https://github.com/nix-community/home-manager/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
            }

            {
              Name = "Hyprland Issues";
              Alias = "hyi";
              IconURL = "https://github.com/favicon.ico";
              URLTemplate = "https://github.com/hyprwm/Hyprland/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
            }

            {
              Name = "Lix Issues";
              Alias = "li";
              IconURL = "https://git.lix.systems/assets/img/favicon.png";
              URLTemplate = "https://git.lix.systems/lix-project/lix/issues?state=open&q={searchTerms}";
            }

            {
              Name = "i3 Issues";
              Alias = "ii";
              IconURL = "https://github.com/favicon.ico";
              URLTemplate = "https://github.com/i3/i3/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
            }

            {
              Name = "Lutris";
              Alias = "l";
              IconURL = "https://lutris.net/favicon.ico";
              URLTemplate = "https://lutris.net/games?q={searchTerms}";
            }

            {
              Name = "Mozilla Web Docs";
              Alias = "mdn";
              IconURL = "https://developer.mozilla.org/favicon-48x48.cbbd161b.png";
              URLTemplate = "https://developer.mozilla.org/en-US/search?q={searchTerms}";
            }

            {
              Name = "MyNixOS Options";
              Alias = "mno";
              IconURL = "https://mynixos.com/favicon.ico";
              URLTemplate = "https://mynixos.com/search?q=option+{searchTerms}";
            }

            {
              Name = "Nix Dev";
              Alias = "nd";
              IconURL = "https://nix.dev/manual/nix/latest/favicon.png";
              URLTemplate = "https://nix.dev/manual/nix/latest?search={searchTerms}";
            }

            {
              Name = "Nix Hub";
              Alias = "nh";
              IconURL = "https://www.nixhub.io/favicon.ico";
              URLTemplate = "https://www.nixhub.io/search?q={searchTerms}";
            }

            {
              Name = "Nix PR";
              Alias = "npr";
              URLTemplate = "https://nixpk.gs/pr-tracker.html?pr={searchTerms}";
            }

            {
              Name = "NixOS Flakes";
              Alias = "nf";
              IconURL = "https://nixos.org/favicon.png";
              URLTemplate = "https://search.nixos.org/flakes?channel=unstable&query={searchTerms}";
            }

            {
              Name = "NixOS Nixpkgs Issues";
              Alias = "ni";
              IconURL = "https://github.com/favicon.ico";
              URLTemplate = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
            }

            {
              Name = "NixOS Options";
              Alias = "no";
              IconURL = "https://nixos.org/favicon.png";
              URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
            }

            {
              Name = "NixOS Packages";
              Alias = "np";
              IconURL = "https://nixos.org/favicon.png";
              URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
            }

            {
              Name = "NixOS Wiki";
              Alias = "nw";
              IconURL = "https://wiki.nixos.org/favicon.ico";
              URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
            }

            {
              Name = "Noogle Dev";
              Alias = "nod";
              IconURL = "https://noogle.dev/favicon.png";
              URLTemplate = "https://noogle.dev/q?term={searchTerms}";
            }

            {
              Name = "PCGamingWiki";
              Alias = "pc";
              IconURL = "https://static.pcgamingwiki.com/favicons/pcgamingwiki.png";
              URLTemplate = "https://www.pcgamingwiki.com/w/index.php?search={searchTerms}";
            }

            {
              Name = "Piped";
              Alias = "p";
              IconURL = "https://piped.bjork.tech/favicon.ico";
              URLTemplate = "https://piped.bjork.tech/results?search_query={searchTerms}";
            }

            {
              Name = "ProtonDB";
              Alias = "pdb";
              IconURL = "https://www.protondb.com/sites/protondb/images/favicon.ico";
              URLTemplate = "https://www.protondb.com/search?q={searchTerms}";
            }

            {
              Name = "PyPI";
              Alias = "pip";
              IconURL = "https://pypi.org/static/images/favicon.35549fe8.ico";
              URLTemplate = "https://pypi.org/search/?q={searchTerms}";
            }

            {
              Name = "Reddit";
              Alias = "r";
              IconURL = "https://www.redditstatic.com/desktop2x/img/favicon/favicon-96x96.png";
              URLTemplate = "https://search.bjork.tech/search?q=site%3Areddit.com+{searchTerms}";
            }

            {
              Name = "SearXNG";
              Alias = "s";
              IconURL = "https://search.bjork.tech/static/themes/simple/img/favicon.png";
              URLTemplate = "https://search.bjork.tech/search?q={searchTerms}";
            }

            {
              Name = "Sway Issues";
              Alias = "si";
              IconURL = "https://github.com/favicon.ico";
              URLTemplate = "https://github.com/swaywm/sway/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
            }

            {
              Name = "Wikipedia";
              Alias = "w";
              IconURL = "https://en.wikipedia.org/static/favicon/wikipedia.ico";
              URLTemplate = "https://en.wikipedia.org/w/index.php?search={searchTerms}";
            }

            {
              Name = "Wolfram Alpha";
              Alias = "wa";
              IconURL = "https://www.wolframalpha.com/_next/static/images/favicon_1zbE9hjk.ico";
              URLTemplate = "https://www.wolframalpha.com/input?i={searchTerms}";
            }

            {
              Name = "YouTube";
              Alias = "y";
              IconURL = "https://www.youtube.com/s/desktop/f8c8418d/img/favicon.ico";
              URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
            }
          ];

          Remove = [
            "Amazon.com"
            "Bing"
            "DuckDuckGo"
            "eBay"
            "Google"
            "Wikipedia (en)"
          ];
        };

        SearchSuggestEnabled = true;
        ShowHomeButton = true;

        UserMessaging = {
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          MoreFromMozilla = false;
          SkipOnboarding = false;
          UrlbarInterventions = false;
          WhatsNew = false;
          Locked = true;
        };
      };
    };

    home.file = {
      # TODO: Consider other themes
      # https://github.com/soulhotel/FF-ULTIMA

      # CSS theme to import into profile
      # https://github.com/rafaelmardojai/firefox-gnome-theme
      ".mozilla/firefox/default/chrome/firefox-gnome-theme".source = inputs.firefox-gnome-theme;

      # Imperative symlinks intended to be synced
      "Downloads/stg" = mkIf config.custom.full {
        source =
          config.home-manager.users.${config.custom.username}.lib.file.mkOutOfStoreSymlink
          "/home/myned/SYNC/common/config/extensions/Simple Tab Groups";
      };

      # Work around icon dissociation due to missing --name flag in actions
      # https://github.com/micheleg/dash-to-dock/issues/1968
      #!! Keep updated with upstream desktop file
      #?? cat /etc/profiles/per-user/myned/share/applications/firefox-esr.desktop
      # ".local/share/applications/firefox-esr.desktop".text = ''
      #   [Desktop Entry]
      #   Actions=new-private-window;new-window;profile-manager-window
      #   Categories=Network;WebBrowser
      #   Exec=firefox --name firefox %U
      #   GenericName=Web Browser
      #   Icon=firefox
      #   MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;x-scheme-handler/http;x-scheme-handler/https
      #   Name=Firefox ESR
      #   StartupNotify=true
      #   StartupWMClass=firefox
      #   Terminal=false
      #   Type=Application
      #   Version=1.4

      #   [Desktop Action new-private-window]
      #   Exec=firefox --name firefox --private-window %U
      #   Name=New Private Window

      #   [Desktop Action new-window]
      #   Exec=firefox --name firefox --new-window %U
      #   Name=New Window

      #   [Desktop Action profile-manager-window]
      #   Exec=firefox --name firefox --ProfileManager
      #   Name=Profile Manager
      # '';
    };
  };
}
