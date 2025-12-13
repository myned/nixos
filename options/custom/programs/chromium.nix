{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.chromium;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.chromium = {
    enable = mkEnableOption "chromium";

    package = mkOption {
      default = pkgs.brave;
      description = "Chromium package to use";
      example = pkgs.google-chrome;
      type = types.package;
    };

    dataDir = mkOption {
      default = "${hm.xdg.configHome}/BraveSoftware/Brave-Browser";
      description = "Path to user data directory";
      example = "${hm.xdg.configHome}/google-chrome";
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Chromium
    # https://www.chromium.org/chromium-projects
    programs.chromium = {
      enable = true;

      # https://chromeenterprise.google/policies/
      #?? chrome://policy
      extraOpts = {
        # HACK: Extensions are force-installed with programs.chromium.extensions option
        # https://support.google.com/chrome/a/answer/9867568
        # https://chromeenterprise.google/policies/#ExtensionSettings
        ExtensionSettings = listToAttrs (map (id: {
            name = id;
            value = {
              installation_mode = "normal_installed";
              update_url = "https://clients2.google.com/service/update2/crx";
            };
          }) (optionals config.custom.default [
              #// "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
              "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
            ]
            ++ optionals config.custom.full [
              #// "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
              #// "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
              #// "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
              #// "enamippconapkdmgfgjchkhakpfinmaj" # DeArrow
              #// "ponfpcnoihfmfllpaingbgckeeldkhle" # Enhancer for YouTube
              #// "fnaicdffflnofjppbagibeoednhnbjhg" # floccus
              #// "bnomihfieiccainjcjblhegjgglakjdd" # Improve YouTube
              #// "pnjaodmkngahhkoihejjehlcdlnohgmp" # RSS Feed Reader
              #// "kfimphpokifbjgmjflanmfeppcjimgah" # RSS Reader Extension (by Inoreader)
              #// "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
              #// "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
              #// "kfidecgcdjjfpeckbblhmfkhmlgecoff" # Svelte DevTools
              #// "nplimhmoanghlebhdiboeellhgmgommi" # Tab Groups Extension
              #// "enboaomnljigfhfjfoalacienlhjlfil" # UnTrap for YouTube
            ]));

        # https://chromeenterprise.google/policies/#DefaultSearchProvider
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = config.custom.search.default.name;
        DefaultSearchProviderKeyword = config.custom.search.default.shortcut;
        DefaultSearchProviderSearchURL = replaceStrings ["%s"] ["{searchTerms}"] config.custom.search.default.searchUrl;
        DefaultSearchProviderSuggestURL = replaceStrings ["%s"] ["{searchTerms}"] config.custom.search.default.suggestUrl;

        # https://chromeenterprise.google/policies/#SiteSearchSettings
        SiteSearchSettings =
          mapAttrsToList (_: value: {
            name = value.title;
            shortcut = value.shortcut;
            url = replaceStrings ["%s"] ["{searchTerms}"] value.searchUrl;
          })
          config.custom.search.engines;
      };
    };

    # https://nix-community.github.io/stylix/options/modules/chromium.html
    stylix.targets.chromium.enable = false;

    home-manager.sharedModules = let
      module = {
        enable = true;

        # https://stackoverflow.com/questions/69363637/how-to-write-argument-for-chrome-chromiums-enable-features-flag
        #?? https://source.chromium.org/chromium/chromium/src/+/main:chrome/browser/about_flags.cc
        commandLineArgs = let
          enable-features = concatStringsSep "," [
            "FluentOverlayScrollbar" # Enable overlay scrollbars
            "TouchpadOverscrollHistoryNavigation" # https://wiki.archlinux.org/title/Chromium#Touchpad_Gestures_for_Navigation
          ];

          disable-features = concatStringsSep "," [
            "EnableTabMuting" # Disable tab mute button
            "GlobalShortcutsPortal" # https://wiki.archlinux.org/title/Chromium#Gnome_%22Global_Shortcuts%22_menu_appears_on_startup
          ];
        in [
          "--enable-features=${enable-features}"
          "--disable-features=${disable-features}"
        ];
      };
    in [
      {
        programs =
          mapAttrs (
            name: value:
              value // module
          ) {
            brave = {};
            chromium = {package = pkgs.google-chrome;};
          };

        # HACK: Create symlink to generated native-messaging-hosts file in custom profile
        systemd.user.tmpfiles.rules = optionals config.programs._1password.enable [
          "L+ ${cfg.dataDir}-Work/NativeMessagingHosts/com.1password.1password.json - - - - ${cfg.dataDir}/NativeMessagingHosts/com.1password.1password.json"
        ];
      }
    ];
  };
}
