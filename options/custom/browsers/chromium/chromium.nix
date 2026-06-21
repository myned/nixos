{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.browsers.chromium;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.browsers.chromium = {
    enable = mkEnableOption "chromium";
  };

  config = mkIf cfg.enable {
    custom.browsers.programs.chromium = {
      appId = "chromium";
      command = ["chromium" "--profile-directory=Default"];
      commandWork = ["chromium" "--profile-directory=Profile 1" "--window-name=Work"];
      desktop = "chromium.desktop";

      # https://stackoverflow.com/questions/69363637/how-to-write-argument-for-chrome-chromiums-enable-features-flag
      #?? https://source.chromium.org/chromium/chromium/src/+/main:chrome/browser/about_flags.cc
      commandLineArgs = let
        enable-features = concatStringsSep "," [
          "OverlayScrollbar" # Enable overlay scrollbars
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

    nixpkgs.overlays = [
      (final: prev: {
        chromium = prev.chromium.override {
          commandLineArgs = config.custom.browsers.programs.chromium.commandLineArgs;
        };
      })
    ];

    # System policy module for chromium-based browsers
    # https://wiki.nixos.org/wiki/Chromium
    # https://www.chromium.org/chromium-projects
    programs.chromium = {
      enable = true;

      # https://chromeenterprise.google/policies/
      #?? chrome://policy
      extraOpts = {
        # https://support.google.com/chrome/a/answer/9867568
        # https://chromeenterprise.google/policies/#ExtensionSettings
        ExtensionSettings = listToAttrs (map (
            id:
              nameValuePair id {
                installation_mode = "normal_installed";
                update_url = "https://clients2.google.com/service/update2/crx";
              }
          ) (optionals config.custom.default [
              #// "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
              #// "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
            ]
            ++ optionals config.custom.full [
              #// "aeblfdkhhhdcdjpifhhbdiojplfjncoa" # 1Password
              #// "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
              #// "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
              #// "enamippconapkdmgfgjchkhakpfinmaj" # DeArrow
              #// "ponfpcnoihfmfllpaingbgckeeldkhle" # Enhancer for YouTube
              #// "fnaicdffflnofjppbagibeoednhnbjhg" # floccus
              #// "bnomihfieiccainjcjblhegjgglakjdd" # Improve YouTube
              "ghmbeldphafepmbegfdlkpapadhbakde" # Proton Pass
              #// "pnjaodmkngahhkoihejjehlcdlnohgmp" # RSS Feed Reader
              #// "kfimphpokifbjgmjflanmfeppcjimgah" # RSS Reader Extension (by Inoreader)
              "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
              #// "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
              #// "kfidecgcdjjfpeckbblhmfkhmlgecoff" # Svelte DevTools
              #// "nplimhmoanghlebhdiboeellhgmgommi" # Tab Groups Extension
              #// "enboaomnljigfhfjfoalacienlhjlfil" # UnTrap for YouTube
            ]));

        # https://chromeenterprise.google/policies/#DefaultSearchProvider
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = config.custom.search.default.name;
        #// DefaultSearchProviderKeyword = config.custom.search.default.shortcut;
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
    #// stylix.targets.chromium.enable = true;

    home-manager.sharedModules = [
      {
        # https://www.chromium.org/chromium-projects/
        # https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
        programs.chromium.enable = true;
      }
    ];
  };
}
