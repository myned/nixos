{
  config,
  inputs,
  lib,
  pkgs,
  theme ? false,
  ...
}:
with lib; {
  #!! Creates package derivation
  #?? hm.programs.firefox.finalPackage
  enableGnomeExtensions = config.services.gnome.gnome-browser-connector.enable;

  # https://wiki.nixos.org/wiki/Firefox#Tips
  nativeMessagingHosts = with pkgs; [
    firefoxpwa
  ];

  #!! Prefer policies over profiles when possible
  #?? about:profiles
  profiles.default = {
    # https://nur.nix-community.org/repos/rycee/
    extensions = with pkgs.nur.repos.rycee.firefox-addons;
      optionals config.custom.minimal [
        ublock-origin
      ]
      ++ optionals config.custom.full [
        #// awesome-rss
        #// betterttv
        bitwarden
        enhancer-for-youtube
        #// firefox-color
        #// gnome-shell-integration
        #// improved-tube
        libredirect
        multi-account-containers
        #// onepassword-password-manager
        pwas-for-firefox
        #// simple-tab-groups
        sponsorblock
        stylus
        #// untrap-for-youtube
        #// user-agent-string-switcher

        # TODO: Convert to NUR addons
        #// "{248e6a49-f636-4c81-9899-a456eb6291a8}" = extension "ground-news-bias-checker"; # Ground News Bias Checker
        #// "select-after-closing-current@qw.linux-2g64.local" = extension "select-after-closing-current"; # Select After Closing Current
        #// "myallychou@gmail.com" = extension "youtube-recommended-videos"; # Unhook: Remove YouTube Recommended Videos Comments
        #// "{a0370179-acc3-452f-9530-246b6adb2768}" = extension "svelte-devtools"; # Svelte Devtools
        #// "{c49b13b1-5dee-4345-925e-0c793377e3fa}" = extension "youtube-enhancer-vc"; # YouTube Enhancer
      ];

    # TODO: Consider other themes
    # https://github.com/soulhotel/FF-ULTIMA

    # BUG: Tab groups not yet supported
    # https://github.com/rafaelmardojai/firefox-gnome-theme/issues/901
    # https://github.com/rafaelmardojai/firefox-gnome-theme
    # https://github.com/rafaelmardojai/firefox-gnome-theme/blob/master/theme/colors/dark.css
    userChrome = ''
      ${
        if theme
        then "@import ${inputs.firefox-gnome-theme}/userChrome.css"
        else ""
      }

      ${builtins.readFile ./userChrome.css}
    '';

    userContent = ''
      ${
        if theme
        then "@import ${inputs.firefox-gnome-theme}/userContent.css"
        else ""
      }

      ${builtins.readFile ./userContent.css}
    '';

    containersForce = true;

    containers = {
      edu = {
        color = "orange";
        icon = "fruit";
        id = 1;
      };
    };

    settings = with config.custom.settings.fonts;
      {
        "accessibility.browsewithcaret" = false;
        "accessibility.typeaheadfind" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.contentblocking.category" = "standard";
        "browser.contentblocking.report.hide_vpn_banner" = true;
        "browser.contentblocking.report.show_mobile_app" = false;
        "browser.contentblocking.report.vpn.enabled" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.ctrlTab.sortByRecentlyUsed" = false;
        "browser.dataFeatureRecommendations.enabled" = false;
        "browser.download.always_ask_before_handling_new_types" = false;
        "browser.download.useDownloadDir" = true;
        "browser.engagement.ctrlTab.has-used" = true;
        "browser.engagement.downloads-button.has-used" = true;
        "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
        "browser.engagement.home-button.has-used" = true;
        "browser.engagement.library-button.has-used" = true;
        "browser.engagement.sidebar-button.has-used" = true;
        "browser.formfill.enable" = false;
        "browser.link.open_newwindow.restriction" = 0; # Popups in new tab
        "browser.link.open_newwindow" = 3; # New tab
        "browser.messaging-system.whatsNewPanel.enabled" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.discoverystream.onboardingExperience.enabled" = false;
        "browser.newtabpage.activity-stream.discoverystream.topicSelection.onboarding.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.recommendationprovider" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.enabled" = true;
        "browser.ping-centre.telemetry" = false;
        "browser.preferences.defaultPerformanceSettings.enabled" = true;
        "browser.preferences.moreFromMozilla" = false;
        "browser.quitShortcut.disabled" = true;
        "browser.safebrowsing.blockedURIs.enabled" = true;
        "browser.safebrowsing.downloads.enabled" = true;
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "browser.search.separatePrivateDefault" = false;
        "browser.search.suggest.enabled" = true;
        "browser.search.widget.inNavBar" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:home";
        "browser.startup.page" = 3; # Previous session
        "browser.tabs.allowTabDetach" = false;
        "browser.tabs.closeTabByDblclick" = true;
        "browser.tabs.closeWindowWithLastTab" = false;
        "browser.tabs.groups.enabled" = true;
        "browser.tabs.insertAfterCurrent" = false;
        "browser.tabs.insertRelatedAfterCurrent" = false;
        "browser.tabs.loadInBackground" = true;
        "browser.tabs.warnOnClose" = false;
        "browser.tabs.warnOnCloseOtherTabs" = false;
        "browser.theme.dark-private-windows" = false;
        "browser.toolbars.bookmarks.showOtherBookmarks" = false;
        "browser.uidensity" = 0; # Default
        "browser.urlbar.quicksuggest.dataCollection.enabled" = false;
        "browser.urlbar.quicksuggest.shouldShowOnboardingDialog" = false;
        "browser.urlbar.suggest.addons" = true;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.calculator" = true;
        "browser.urlbar.suggest.clipboard" = true;
        "browser.urlbar.suggest.engines" = true;
        "browser.urlbar.suggest.fakespot" = true;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.mdn" = true;
        "browser.urlbar.suggest.openpage" = true;
        "browser.urlbar.suggest.pocket" = false;
        "browser.urlbar.suggest.quickactions" = true;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = true;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.recentsearches" = true;
        "browser.urlbar.suggest.remotetab" = true;
        "browser.urlbar.suggest.searches" = true;
        "browser.urlbar.suggest.topsites" = true;
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.suggest.weather" = false;
        "browser.urlbar.suggest.yelp" = false;
        "browser.warnOnQuitShortcut" = true;
        "clipboard.autocopy" = false;
        "default-browser-agent.enabled" = false;
        "devtools.webconsole.input.editorOnboarding" = false;
        "dom.security.https_only_mode" = true;
        "extensions.autoDisableScopes" = 0; # Auto-enable extensions
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
        "extensions.pocket.enabled" = false;
        "extensions.update.autoUpdateDefault" = true;
        "extensions.update.enabled" = true;
        "font.default.x-unicode" = sans-serif;
        "font.default.x-western" = sans-serif;
        "font.name-list.emoji" = emoji; # System emoji
        "font.name.monospace.x-unicode" = monospace;
        "font.name.monospace.x-western" = monospace;
        "font.name.sans-serif.x-unicode" = sans-serif;
        "font.name.sans-serif.x-western" = sans-serif;
        "font.name.serif.x-unicode" = sans-serif;
        "font.name.serif.x-western" = sans-serif;
        "full-screen-api.ignore-widgets" = false; # Fake fullscreen
        "full-screen-api.warning.delay" = -1;
        "full-screen-api.warning.timeout" = 0;
        "general.autoScroll" = false;
        "general.smoothScroll" = true;
        "general.smoothScroll.msdPhysics.enabled" = true;
        "gfx.webrender.software" = false;
        "identity.fxaccounts.enabled" = true;
        "layers.acceleration.force-enabled" = true;
        "layout.css.always_underline_links" = false;
        "layout.css.backdrop-filter.enabled" = true;
        "layout.forms.reveal-password-button.enabled" = true;
        "layout.forms.reveal-password-context-menu.enabled" = false;
        "layout.spellcheckDefault" = 0; # Disabled
        "media.autoplay.blocking_policy" = 1; # Transient
        "media.eme.enabled" = true; # DRM
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "media.hardwaremediakeys.enabled" = true;
        "media.videocontrols.picture-in-picture.audio-toggle.enabled" = false;
        "media.videocontrols.picture-in-picture.display-text-tracks.enabled" = true;
        "media.videocontrols.picture-in-picture.display-text-tracks.toggle.enabled" = true;
        "media.videocontrols.picture-in-picture.enable-when-switching-tabs.enabled" = true;
        "media.videocontrols.picture-in-picture.enabled" = true;
        "media.videocontrols.picture-in-picture.respect-disablePictureInPicture" = false;
        "media.videocontrols.picture-in-picture.urlbar-button.enabled" = true;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
        "media.videocontrols.picture-in-picture.video-toggle.has-used" = true;
        "media.videocontrols.picture-in-picture.video-toggle.min-video-secs" = 0; # No minimum duration
        "media.videocontrols.picture-in-picture.video-toggle.position" = "right";
        "messaging-system.askForFeedback" = false;
        "messaging-system.rsexperimentloader.enabled" = false;
        "middlemouse.paste" = false;
        "network.dns.disableIPv6" = false;
        "network.dns.disablePrefetch" = true;
        "network.dns.disablePrefetchFromHTTPS" = true;
        "network.http.referer.XOriginPolicy" = 0; # Relaxed
        "network.predictor.enabled" = false;
        "pref.privacy.disable_button.view_passwords" = false;
        "privacy.fingerprintingProtection" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.resistFingerprinting.autoDeclineNoUserInputCanvasPrompts" = false;
        "privacy.resistFingerprinting.letterboxing" = false;
        "privacy.resistFingerprinting" = false; #!! Forces light theme
        "remote.prefs.recommended" = false;
        "security.OCSP.require" = true;
        "security.protectionspopup.recordEventTelemetry" = false;
        "services.passwordSavingEnabled" = false;
        "startup.homepage_override_url" = ""; # Disable
        "startup.homepage_welcome_url" = ""; # Disable
        "svg.context-properties.content.enabled" = true; # Dark theme icons
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.pioneer-new-studies-available" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "ui.key.menuAccessKey" = 0; # Disable menu key
        "webgl.disabled" = false;
        "widget.gtk.overlay-scrollbars.enabled" = true;
        "widget.gtk.rounded-bottom-corners.enabled" = true;
      }
      // optionalAttrs theme {
        # https://github.com/rafaelmardojai/firefox-gnome-theme?tab=readme-ov-file#features
        "gnomeTheme.allTabsButtonOnOverflow" = true;
        "gnomeTheme.bookmarksToolbarUnderTabs" = true;
      };

    # https://searchfox.org/mozilla-central/rev/669329e284f8e8e2bb28090617192ca9b4ef3380/toolkit/components/search/SearchEngine.jsm#1138-1177
    search = {
      force = true;
      default = "Kagi";
      privateDefault = "Kagi";

      engines = {
        ### Builtins
        "Amazon.com" = {
          metaData.hidden = true;
        };

        "Bing" = {
          metaData.hidden = true;
        };

        "DuckDuckGo" = {
          metaData.alias = "d";
        };

        "eBay" = {
          metaData.hidden = true;
        };

        "Google" = {
          metaData.alias = "g";
        };

        "Wikipedia (en)" = {
          metaData.hidden = true;
        };

        ### Custom
        "Amazon" = {
          definedAliases = ["a"];
          iconUpdateURL = "https://www.amazon.com/favicon.ico";
          urls = [{template = "https://www.amazon.com/s?k={searchTerms}";}];
        };

        "ArchWiki" = {
          definedAliases = ["aw"];
          iconUpdateURL = "https://wiki.archlinux.org/favicon.ico";
          urls = [{template = "https://wiki.archlinux.org/index.php?search={searchTerms}";}];
        };

        "Brave" = {
          definedAliases = ["b"];
          iconUpdateURL = "https://cdn.search.brave.com/serp/v2/_app/immutable/assets/favicon.c09fe1a1.ico";
          urls = [{template = "https://search.brave.com/search?q={searchTerms}";}];
        };

        "Docker Hub" = {
          definedAliases = ["dh"];
          iconUpdateURL = "https://hub.docker.com/favicon.ico";
          urls = [{template = "https://hub.docker.com/search?q={searchTerms}";}];
        };

        "e621" = {
          definedAliases = ["e"];
          iconUpdateURL = "https://e621.net/favicon.ico";
          urls = [{template = "https://e621.net/posts?tags={searchTerms}";}];
        };

        "Element Issues" = {
          definedAliases = ["ei"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/element-hq/element-web/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "Flathub" = {
          definedAliases = ["fh"];
          iconUpdateURL = "https://flathub.org/favicon.png";
          urls = [{template = "https://flathub.org/apps/search?q={searchTerms}";}];
        };

        "Google Fonts" = {
          definedAliases = ["gf"];
          iconUpdateURL = "https://www.gstatic.com/images/icons/material/apps/fonts/1x/catalog/v5/favicon.svg";
          urls = [{template = "https://fonts.google.com/?query={searchTerms}";}];
        };

        "GitHub" = {
          definedAliases = ["gh"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/search?q={searchTerms}";}];
        };

        "Home Manager Issues" = {
          definedAliases = ["hi"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/nix-community/home-manager/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "Home Manager Options" = {
          definedAliases = ["ho"];
          iconUpdateURL = "https://home-manager-options.extranix.com/images/favicon.png";
          urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";}];
        };

        "Hyprland Issues" = {
          definedAliases = ["hyi"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/hyprwm/Hyprland/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "i3 Issues" = {
          definedAliases = ["ii"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/i3/i3/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "Kagi" = {
          definedAliases = ["k"];
          iconUpdateURL = "https://kagi.com/asset/v2/favicon-32x32.png";
          urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
        };

        "Lutris" = {
          definedAliases = ["l"];
          iconUpdateURL = "https://lutris.net/favicon.ico";
          urls = [{template = "https://lutris.net/games?q={searchTerms}";}];
        };

        "Lix Issues" = {
          definedAliases = ["li"];
          iconUpdateURL = "https://git.lix.systems/assets/img/favicon.png";
          urls = [{template = "https://git.lix.systems/lix-project/lix/issues?state=open&q={searchTerms}";}];
        };

        "Mozilla Web Docs" = {
          definedAliases = ["mdn"];
          iconUpdateURL = "https://developer.mozilla.org/favicon-48x48.cbbd161b.png";
          urls = [{template = "https://developer.mozilla.org/en-US/search?q={searchTerms}";}];
        };

        "MyNixOS Options" = {
          definedAliases = ["mno"];
          iconUpdateURL = "https://mynixos.com/favicon.ico";
          urls = [{template = "https://mynixos.com/search?q=option+{searchTerms}";}];
        };

        "Nix Dev" = {
          definedAliases = ["nd"];
          iconUpdateURL = "https://nix.dev/manual/nix/latest/favicon.png";
          urls = [{template = "https://nix.dev/manual/nix/latest?search={searchTerms}";}];
        };

        "NixOS Flakes" = {
          definedAliases = ["nf"];
          iconUpdateURL = "https://nixos.org/favicon.png";
          urls = [{template = "https://search.nixos.org/flakes?channel=unstable&query={searchTerms}";}];
        };

        "Nix Hub" = {
          definedAliases = ["nh"];
          iconUpdateURL = "https://www.nixhub.io/favicon.ico";
          urls = [{template = "https://www.nixhub.io/search?q={searchTerms}";}];
        };

        "NixOS Nixpkgs Issues" = {
          definedAliases = ["ni"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "Nix PR" = {
          definedAliases = ["npr"];
          urls = [{template = "https://nixpk.gs/pr-tracker.html?pr={searchTerms}";}];
        };

        "NixOS Options" = {
          definedAliases = ["no"];
          iconUpdateURL = "https://nixos.org/favicon.png";
          urls = [{template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";}];
        };

        "Noogle Dev" = {
          definedAliases = ["nod"];
          iconUpdateURL = "https://noogle.dev/favicon.png";
          urls = [{template = "https://noogle.dev/q?term={searchTerms}";}];
        };

        "NixOS Packages" = {
          definedAliases = ["np"];
          iconUpdateURL = "https://nixos.org/favicon.png";
          urls = [{template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";}];
        };

        "Niri Issues" = {
          definedAliases = ["nii"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/YaLTeR/niri/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "NixOS Wiki" = {
          definedAliases = ["nw"];
          iconUpdateURL = "https://wiki.nixos.org/favicon.ico";
          urls = [{template = "https://wiki.nixos.org/w/index.php?search={searchTerms}";}];
        };

        "Piped" = {
          definedAliases = ["p"];
          iconUpdateURL = "https://piped.${config.custom.domain}/favicon.ico";
          urls = [{template = "https://piped.${config.custom.domain}/results?search_query={searchTerms}";}];
        };

        "PCGamingWiki" = {
          definedAliases = ["pc"];
          iconUpdateURL = "https://static.pcgamingwiki.com/favicons/pcgamingwiki.png";
          urls = [{template = "https://www.pcgamingwiki.com/w/index.php?search={searchTerms}";}];
        };

        "ProtonDB" = {
          definedAliases = ["pdb"];
          iconUpdateURL = "https://www.protondb.com/sites/protondb/images/favicon.ico";
          urls = [{template = "https://www.protondb.com/search?q={searchTerms}";}];
        };

        "PyPI" = {
          definedAliases = ["pip"];
          iconUpdateURL = "https://pypi.org/static/images/favicon.35549fe8.ico";
          urls = [{template = "https://pypi.org/search/?q={searchTerms}";}];
        };

        "Reddit" = {
          definedAliases = ["r"];
          iconUpdateURL = "https://www.redditstatic.com/desktop2x/img/favicon/favicon-96x96.png";
          urls = [{template = "https://kagi.com/search?q=site%3Areddit.com+{searchTerms}";}];
        };

        "SearXNG" = {
          definedAliases = ["s"];
          iconUpdateURL = "https://search.${config.custom.domain}/static/themes/simple/img/favicon.png";
          urls = [{template = "https://search.${config.custom.domain}/search?q={searchTerms}";}];
        };

        "Sway Issues" = {
          definedAliases = ["si"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/swaywm/sway/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "Wikipedia" = {
          definedAliases = ["w"];
          iconUpdateURL = "https://en.wikipedia.org/static/favicon/wikipedia.ico";
          urls = [{template = "https://en.wikipedia.org/w/index.php?search={searchTerms}";}];
        };

        "Wolfram Alpha" = {
          definedAliases = ["wa"];
          iconUpdateURL = "https://www.wolframalpha.com/_next/static/images/favicon_1zbE9hjk.ico";
          urls = [{template = "https://www.wolframalpha.com/input?i={searchTerms}";}];
        };

        "Walker Issues" = {
          definedAliases = ["wi"];
          iconUpdateURL = "https://github.com/favicon.ico";
          urls = [{template = "https://github.com/abenz1267/walker/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";}];
        };

        "YouTube" = {
          definedAliases = ["y"];
          iconUpdateURL = "https://www.youtube.com/s/desktop/f8c8418d/img/favicon.ico";
          urls = [{template = "https://www.youtube.com/results?search_query={searchTerms}";}];
        };
      };
    };
  };
}
