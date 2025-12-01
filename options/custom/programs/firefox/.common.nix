{
  config,
  lib,
  pkgs,
  telemetry ? false,
  theme ? false,
  ...
}:
with lib; {
  #!! Creates package derivation
  #?? hm.programs.firefox.finalPackage
  # https://wiki.nixos.org/wiki/Firefox#Tips_and_Tricks
  nativeMessagingHosts = with pkgs; [
    firefoxpwa
  ];

  #!! Prefer policies over profiles when possible
  #?? about:profiles
  profiles = rec {
    default = {
      # https://nur.nix-community.org/repos/rycee/
      # extensions.packages = with pkgs.nur.repos.rycee.firefox-addons;
      #   optionals config.custom.minimal [
      #     ublock-origin
      #   ]
      #   ++ optionals config.custom.full [
      #     #// awesome-rss
      #     #// betterttv
      #     bitwarden
      #     #// enhancer-for-youtube
      #     #// firefox-color
      #     #// gnome-shell-integration
      #     #// improved-tube
      #     libredirect
      #     multi-account-containers
      #     #// onepassword-password-manager
      #     pwas-for-firefox
      #     #// simple-tab-groups
      #     sponsorblock
      #     stylus
      #     #// untrap-for-youtube
      #     #// user-agent-string-switcher

      #     # TODO: Convert to NUR addons
      #     #// "{248e6a49-f636-4c81-9899-a456eb6291a8}" = extension "ground-news-bias-checker"; # Ground News Bias Checker
      #     #// "select-after-closing-current@qw.linux-2g64.local" = extension "select-after-closing-current"; # Select After Closing Current
      #     #// "myallychou@gmail.com" = extension "youtube-recommended-videos"; # Unhook: Remove YouTube Recommended Videos Comments
      #     #// "{a0370179-acc3-452f-9530-246b6adb2768}" = extension "svelte-devtools"; # Svelte Devtools
      #     #// "{c49b13b1-5dee-4345-925e-0c793377e3fa}" = extension "youtube-enhancer-vc"; # YouTube Enhancer
      #   ];

      # TODO: Consider other themes
      # https://github.com/soulhotel/FF-ULTIMA
      #!! @import must be above other rules
      # https://github.com/rafaelmardojai/firefox-gnome-theme/blob/master/theme/colors/dark.css
      userChrome = mkAfter ''@import "${./customChrome.css}";'';
      userContent = mkAfter ''@import "${./customContent.css}";'';

      # containersForce = true;

      # containers = {
      #   work = {
      #     color = "red";
      #     icon = "briefcase";
      #     id = 1;
      #   };

      #   edu = {
      #     color = "orange";
      #     icon = "fruit";
      #     id = 2;
      #   };

      #   temp = {
      #     color = "toolbar";
      #     icon = "fingerprint";
      #     id = 9;
      #   };
      # };

      settings =
        {
          "accessibility.browsewithcaret" = false;
          "accessibility.typeaheadfind" = false;
          "app.shield.optoutstudies.enabled" = true;
          "apz.gtk.pangesture.delta_mode" = 2; # pixel
          "apz.gtk.pangesture.pixel_delta_mode_multiplier" = 30.0; # Touchpad scroll speed
          "browser.aboutConfig.showWarning" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.contentblocking.category" = "standard";
          "browser.contentblocking.report.hide_vpn_banner" = true;
          "browser.contentblocking.report.show_mobile_app" = false;
          "browser.contentblocking.report.vpn.enabled" = false;
          "browser.ctrlTab.sortByRecentlyUsed" = false;
          "browser.dataFeatureRecommendations.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.display.use_document_fonts" = 1; # 0 = force custom fonts
          "browser.download.always_ask_before_handling_new_types" = false;
          "browser.download.alwaysOpenPanel" = true;
          "browser.download.autohideButton" = true;
          "browser.download.panel.shown" = true;
          "browser.download.useDownloadDir" = true;
          "browser.engagement.ctrlTab.has-used" = true;
          "browser.engagement.downloads-button.has-used" = true;
          "browser.engagement.fxa-toolbar-menu-button.has-used" = true;
          "browser.engagement.home-button.has-used" = true;
          "browser.engagement.library-button.has-used" = true;
          "browser.engagement.sidebar-button.has-used" = true;
          "browser.formfill.enable" = false;
          "browser.link.open_newwindow" = 3; # New tab
          "browser.link.open_newwindow.restriction" = 0; # Popups in new tab
          "browser.messaging-system.whatsNewPanel.enabled" = false;
          "browser.ml.chat.page" = false;
          "browser.ml.linkPreview.collapsed" = false;
          "browser.ml.linkPreview.enabled" = false;
          "browser.ml.linkPreview.longPress" = false;
          "browser.ml.linkPreview.shift" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.discoverystream.onboardingExperience.enabled" = false;
          "browser.newtabpage.activity-stream.discoverystream.topicSelection.onboarding.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.recommendationprovider" = false;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.showWeather" = false;
          "browser.newtabpage.enabled" = true;
          "browser.preferences.defaultPerformanceSettings.enabled" = true;
          "browser.preferences.moreFromMozilla" = false;
          "browser.quitShortcut.disabled" = true;
          "browser.safebrowsing.blockedURIs.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;
          "browser.search.separatePrivateDefault" = true;
          "browser.search.separatePrivateDefault.ui.enabled" = true;
          "browser.search.suggest.enabled" = true;
          "browser.search.widget.inNavBar" = false;
          "browser.sessionstore.restore_hidden_tabs" = false;
          "browser.sessionstore.restore_on_demand" = true;
          "browser.sessionstore.restore_pinned_tabs_on_demand" = true;
          "browser.sessionstore.restore_tabs_lazily" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.startup.homepage" = "about:home";
          "browser.startup.page" = 3; # Previous session
          "browser.tabs.allowTabDetach" = true;
          "browser.tabs.closeTabByDblclick" = true;
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.tabs.groups.enabled" = true;
          "browser.tabs.groups.smart.userEnabled" = false; # Tab group suggestions
          "browser.tabs.insertAfterCurrent" = false;
          "browser.tabs.insertRelatedAfterCurrent" = true;
          "browser.tabs.loadInBackground" = true;
          "browser.tabs.warnOnClose" = false;
          "browser.tabs.warnOnCloseOtherTabs" = false;
          "browser.theme.dark-private-windows" = false;
          "browser.toolbarbuttons.introduced.sidebar-button" = true;
          "browser.toolbars.bookmarks.showOtherBookmarks" = false;
          "browser.toolbars.bookmarks.visibility" = "newtab";
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
          "dom.private-attribution.submission.enabled" = false;
          "dom.security.https_only_mode" = false;
          "extensions.autoDisableScopes" = 0; # Auto-enable extensions
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
          "extensions.pocket.enabled" = false;
          "extensions.update.autoUpdateDefault" = false;
          "extensions.update.enabled" = false;
          "font.default.x-western" = "sans-serif";
          "font.name.monospace.x-western" = config.stylix.fonts.monospace.name;
          "font.name.sans-serif.x-western" = config.stylix.fonts.sansSerif.name;
          "font.name.serif.x-western" = config.stylix.fonts.serif.name;
          "full-screen-api.ignore-widgets" = true; # Fake fullscreen
          "full-screen-api.warning.delay" = -1;
          "full-screen-api.warning.timeout" = 0;
          "general.autoScroll" = false;
          "general.smoothScroll" = true;
          "general.smoothScroll.msdPhysics.enabled" = false;
          "geo.provider.network.url" = "https://api.beacondb.net/v1/geolocate"; # https://beacondb.net/
          "geo.provider.use_geoclue" = false; # FIXME: geoclue2 not allowed via desktop id
          "gfx.webrender.software" = false;
          "identity.fxaccounts.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layout.css.always_underline_links" = false;
          "layout.css.backdrop-filter.enabled" = true;
          "layout.forms.reveal-password-button.enabled" = false;
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
          "media.videocontrols.picture-in-picture.urlbar-button.enabled" = false;
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
          "network.trr.mode" = 5; # DoH off, default: 0
          "pref.privacy.disable_button.view_passwords" = false;
          "privacy.clearOnShutdown.downloads" = true;
          "privacy.clearOnShutdown.formdata" = true;
          "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
          "privacy.clearOnShutdown_v2.cache" = true;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.donottrackheader.enabled" = false;
          "privacy.fingerprintingProtection" = true;
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.resistFingerprinting.autoDeclineNoUserInputCanvasPrompts" = false;
          "privacy.resistFingerprinting.letterboxing" = false;
          "privacy.resistFingerprinting" = false; #!! Forces light theme
          "privacy.trackingprotection.enabled" = true;
          "privacy.userContext.enabled" = false; # Container tabs
          "remote.prefs.recommended" = false;
          "security.OCSP.require" = false;
          "security.tls.version.enable-deprecated" = true; # IPMI
          "services.passwordSavingEnabled" = false;
          "sidebar.expandOnHoverMessage.dismissed" = true;
          "sidebar.main.tools" = ""; # aichat,syncedtabs,history
          "sidebar.new-sidebar.has-used" = true;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "signon.rememberSignons" = false;
          "startup.homepage_override_url" = ""; # Disable
          "startup.homepage_welcome_url" = ""; # Disable
          "svg.context-properties.content.enabled" = true; # Dark theme icons
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "ui.key.menuAccessKey" = 0; # Disable menu key
          "webgl.disabled" = false;
          "widget.gtk.overlay-scrollbars.enabled" = true;
          "widget.gtk.rounded-bottom-corners.enabled" = true;

          #!! Telemetry
          "browser.crashReports.unsubmittedCheck.autoSubmit2" = telemetry;
          "browser.newtabpage.activity-stream.feeds.telemetry" = telemetry;
          "browser.newtabpage.activity-stream.telemetry" = telemetry;
          "browser.newtabpage.activity-stream.telemetry.ut.events" = telemetry;
          "browser.ping-centre.telemetry" = telemetry;
          "browser.search.serpEventTelemetryCategorization.enabled" = telemetry;
          "browser.search.serpEventTelemetryCategorization.regionEnabled" = telemetry;
          "identity.fxaccounts.telemetry.clientAssociationPing.enabled" = telemetry;
          "network.trr.confirmation_telemetry_enabled" = telemetry;
          "nimbus.telemetry.targetingContextEnabled" = telemetry;
          "security.protectionspopup.recordEventTelemetry" = telemetry;
          "toolkit.telemetry.archive.enabled" = telemetry;
          "toolkit.telemetry.bhrPing.enabled" = telemetry;
          "toolkit.telemetry.coverage.opt-out" = !telemetry;
          "toolkit.telemetry.enabled" = telemetry;
          "toolkit.telemetry.firstShutdownPing.enabled" = telemetry;
          "toolkit.telemetry.newProfilePing.enabled" = telemetry;
          "toolkit.telemetry.pioneer-new-studies-available" = telemetry;
          "toolkit.telemetry.reportingpolicy.firstRun" = telemetry;
          "toolkit.telemetry.shutdownPingSender.enabled" = telemetry;
          "toolkit.telemetry.unified" = telemetry;
          "toolkit.telemetry.updatePing.enabled" = telemetry;
        }
        // optionalAttrs theme {
          # https://github.com/rafaelmardojai/firefox-gnome-theme?tab=readme-ov-file#features
          "gnomeTheme.allTabsButton" = true;
          "gnomeTheme.allTabsButtonOnOverflow" = false;
          "gnomeTheme.bookmarksToolbarUnderTabs" = true;
        };

      # https://searchfox.org/mozilla-central/rev/669329e284f8e8e2bb28090617192ca9b4ef3380/toolkit/components/search/SearchEngine.jsm#1138-1177
      search = {
        force = true;
        default = config.custom.search.default.name;
        privateDefault = config.custom.search.default.name;

        engines =
          {
            ### Builtins
            bing.metaData.hidden = true;
            ddg.metaData.hidden = true;
            ebay.metaData.hidden = true;
          }
          // mapAttrs (_: value: {
            name = value.title;
            definedAliases = [value.shortcut];
            icon = value.iconUrl;
            urls = [{template = replaceStrings ["%s"] ["{searchTerms}"] value.searchUrl;}];
          })
          config.custom.search.engines;
      };
    };

    work =
      default
      // {
        id = 1;

        userChrome = mkAfter ''
          @import "${./customChrome.css}";

          :root {
            --gnome-accent: #cb4b16;
          }
        '';
      };
  };
}
