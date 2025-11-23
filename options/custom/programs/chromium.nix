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
        DefaultSearchProviderKeyword = "g";
        DefaultSearchProviderName = "Google";
        DefaultSearchProviderSearchURL = "{google:baseURL}search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}ie={inputEncoding}";
        DefaultSearchProviderSuggestURL = "{google:baseURL}complete/search?output=chrome&q={searchTerms}";

        # https://chromeenterprise.google/policies/#SiteSearchSettings
        SiteSearchSettings = [
          {
            name = "Google AI Mode";
            shortcut = "a";
            url = "https://google.com/aimode?q={searchTerms}";
          }

          {
            name = "Amazon";
            shortcut = "az";
            url = "https://www.amazon.com/s?k={searchTerms}";
          }

          {
            name = "ArchWiki";
            shortcut = "aw";
            url = "https://wiki.archlinux.org/index.php?search={searchTerms}";
          }

          {
            name = "Brave";
            shortcut = "b";
            url = "https://search.brave.com/search?q={searchTerms}";
          }

          {
            name = "Brave Summary";
            shortcut = "bs";
            url = "https://search.brave.com/search?summary=1&q={searchTerms}";
          }

          {
            name = "DuckDuckGo";
            shortcut = "d";
            url = "https://duckduckgo.com/?q={searchTerms}";
          }

          {
            name = "Docker Hub";
            shortcut = "dh";
            url = "https://hub.docker.com/search?q={searchTerms}";
          }

          {
            name = "e621";
            shortcut = "e";
            url = "https://e621.net/posts?tags={searchTerms}";
          }

          {
            name = "Element Issues";
            shortcut = "ei";
            url = "https://github.com/element-hq/element-web/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "Extensions";
            shortcut = "ex";
            url = "https://chromewebstore.google.com/search/{searchTerms}";
          }

          {
            name = "Forums";
            shortcut = "f";
            url = "https://kagi.com/search?l=3&q={searchTerms}";
          }

          {
            name = "Flathub";
            shortcut = "fh";
            url = "https://flathub.org/apps/search?q={searchTerms}";
          }

          {
            name = "GitHub";
            shortcut = "gh";
            url = "https://github.com/search?q={searchTerms}";
          }

          {
            name = "GitHub";
            shortcut = "gh";
            url = "https://github.com/search?q={searchTerms}";
          }

          {
            name = "Google";
            shortcut = "g";
            url = "{google:baseURL}search?q={searchTerms}&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:searchClient}{google:sourceId}ie={inputEncoding}";
          }

          {
            name = "Home Manager Issues";
            shortcut = "hi";
            url = "https://github.com/nix-community/home-manager/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "Home Manager Options";
            shortcut = "ho";
            url = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
          }

          {
            name = "Hyprland Issues";
            shortcut = "hyi";
            url = "https://github.com/hyprwm/Hyprland/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "Images";
            shortcut = "i";
            url = "https://kagi.com/images?q={searchTerms}";
          }

          {
            name = "i3 Issues";
            shortcut = "ii";
            url = "https://github.com/i3/i3/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "Kagi";
            shortcut = "k";
            url = "https://kagi.com/search?q={searchTerms}";
          }

          {
            name = "Kagi Assistant";
            shortcut = "ka";
            url = "https://kagi.com/assistant?q={searchTerms}";
          }

          {
            name = "Lutris";
            shortcut = "l";
            url = "https://lutris.net/games?q={searchTerms}";
          }

          {
            name = "Lix Issues";
            shortcut = "li";
            url = "https://git.lix.systems/lix-project/lix/issues?state=open&q={searchTerms}";
          }

          {
            name = "Maps";
            shortcut = "m";
            url = "https://www.google.com/maps/search/{searchTerms}";
          }

          {
            name = "Mozilla Web Docs";
            shortcut = "mdn";
            url = "https://developer.mozilla.org/en-US/search?q={searchTerms}";
          }

          {
            name = "MyNixOS Options";
            shortcut = "mno";
            url = "https://mynixos.com/search?q=option+{searchTerms}";
          }

          {
            name = "Nix Dev";
            shortcut = "nd";
            url = "https://nix.dev/manual/nix/latest?search={searchTerms}";
          }

          {
            name = "NixOS Flakes";
            shortcut = "nf";
            url = "https://search.nixos.org/flakes?channel=unstable&query={searchTerms}";
          }

          {
            name = "Nix Hub";
            shortcut = "nh";
            url = "https://www.nixhub.io/search?q={searchTerms}";
          }

          {
            name = "NixOS Nixpkgs Issues";
            shortcut = "ni";
            url = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "NixOS Options";
            shortcut = "no";
            url = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
          }

          {
            name = "Noogle Dev";
            shortcut = "nod";
            url = "https://noogle.dev/q?term={searchTerms}";
          }

          {
            name = "NixOS Packages";
            shortcut = "np";
            url = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
          }

          {
            name = "Nix PR";
            shortcut = "npr";
            url = "https://nixpk.gs/pr-tracker.html?pr={searchTerms}";
          }

          {
            name = "Niri Issues";
            shortcut = "nii";
            url = "https://github.com/YaLTeR/niri/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "NixOS Wiki";
            shortcut = "nw";
            url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
          }

          {
            name = "Ollama";
            shortcut = "ol";
            url = "https://ollama.com/search?q={searchTerms}";
          }

          {
            name = "Open WebUI";
            shortcut = "ow";
            url = "https://ai.vpn.${config.custom.domain}/?temporary-chat=true&q={searchTerms}";
          }

          {
            name = "PCGamingWiki";
            shortcut = "pc";
            url = "https://www.pcgamingwiki.com/w/index.php?search={searchTerms}";
          }

          {
            name = "Perplexity";
            shortcut = "p";
            url = "https://perplexity.ai/?q={searchTerms}";
          }

          {
            name = "ProtonDB";
            shortcut = "pdb";
            url = "https://www.protondb.com/search?q={searchTerms}";
          }

          {
            name = "PyPI";
            shortcut = "pip";
            url = "https://pypi.org/search/?q={searchTerms}";
          }

          {
            name = "Reddit";
            shortcut = "r";
            url = "https://kagi.com/search?q=site%3Areddit.com+{searchTerms}";
          }

          {
            name = "SearXNG";
            shortcut = "s";
            url = "https://search.vpn.${config.custom.domain}/search?q={searchTerms}";
          }

          {
            name = "SteamGridDB";
            shortcut = "sgdb";
            url = "https://www.steamgriddb.com/search/grids?term={searchTerms}";
          }

          {
            name = "Sway Issues";
            shortcut = "si";
            url = "https://github.com/swaywm/sway/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "Verbatim";
            shortcut = "v";
            url = "https://kagi.com/search?verbatim=1&q={searchTerms}";
          }

          {
            name = "Wikipedia";
            shortcut = "w";
            url = "https://en.wikipedia.org/w/index.php?search={searchTerms}";
          }

          {
            name = "Wolfram Alpha";
            shortcut = "wa";
            url = "https://www.wolframalpha.com/input?i={searchTerms}";
          }

          {
            name = "Walker Issues";
            shortcut = "wi";
            url = "https://github.com/abenz1267/walker/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "YouTube";
            shortcut = "y";
            url = "https://www.youtube.com/results?search_query={searchTerms}";
          }

          {
            name = "Piped";
            shortcut = "yp";
            url = "https://piped.vpn.${config.custom.domain}/results?search_query={searchTerms}";
          }

          {
            name = "Zed Issues";
            shortcut = "zi";
            url = "https://github.com/zed-industries/zed/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }
        ];
      };
    };

    # https://nix-community.github.io/stylix/options/modules/chromium.html
    stylix.targets.chromium.enable = false;

    home-manager.users.${config.custom.username} = let
      module = {
        enable = true;

        # https://stackoverflow.com/questions/69363637/how-to-write-argument-for-chrome-chromiums-enable-features-flag
        #?? https://source.chromium.org/chromium/chromium/src/+/main:chrome/browser/about_flags.cc
        commandLineArgs = let
          enable-features = concatStringsSep "," [
            # https://wiki.archlinux.org/title/Chromium#Touchpad_Gestures_for_Navigation
            "TouchpadOverscrollHistoryNavigation"
          ];

          disable-features = concatStringsSep "," [
            # https://wiki.archlinux.org/title/Chromium#Gnome_%22Global_Shortcuts%22_menu_appears_on_startup
            "GlobalShortcutsPortal"
          ];
        in [
          "--enable-features=${enable-features}"
          "--disable-features=${disable-features}"
          "--password-store=auto"
        ];
      };
    in {
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
    };
  };
}
