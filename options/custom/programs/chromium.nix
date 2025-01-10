{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.chromium;
in {
  options.custom.programs.chromium = {
    enable = mkOption {default = false;};
    package = mkOption {default = pkgs.google-chrome;};
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
              "khgocmkkpikpnmmkgmdnfckapcdkgfaf" # 1Password Beta
              #// "ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
              #// "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
              #// "enamippconapkdmgfgjchkhakpfinmaj" # DeArrow
              "ponfpcnoihfmfllpaingbgckeeldkhle" # Enhancer for YouTube
              #// "fnaicdffflnofjppbagibeoednhnbjhg" # floccus
              #// "bnomihfieiccainjcjblhegjgglakjdd" # Improve YouTube
              #// "pnjaodmkngahhkoihejjehlcdlnohgmp" # RSS Feed Reader
              "kfimphpokifbjgmjflanmfeppcjimgah" # RSS Reader Extension (by Inoreader)
              "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
              "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
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
            name = "Amazon";
            shortcut = "a";
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
            name = "i3 Issues";
            shortcut = "ii";
            url = "https://github.com/i3/i3/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
          }

          {
            name = "Kagi";
            shortcut = "k";
            url = "https://kagi.com?q={searchTerms}";
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
            name = "Niri Issues";
            shortcut = "niri";
            url = "https://github.com/YaLTeR/niri/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
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
            name = "NixOS Wiki";
            shortcut = "nw";
            url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
          }

          {
            name = "Piped";
            shortcut = "p";
            url = "https://piped.bjork.tech/results?search_query={searchTerms}";
          }

          {
            name = "PCGamingWiki";
            shortcut = "pc";
            url = "https://www.pcgamingwiki.com/w/index.php?search={searchTerms}";
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
            url = "https://www.google.com/search?q=site%3Areddit.com+{searchTerms}";
          }

          {
            name = "SearXNG";
            shortcut = "s";
            url = "https://search.bjork.tech/search?q={searchTerms}";
          }

          {
            name = "Sway Issues";
            shortcut = "si";
            url = "https://github.com/swaywm/sway/issues?q=is%3Aissue+is%3Aopen+{searchTerms}";
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
        ];
      };
    };

    home-manager.users.${config.custom.username} = {
      programs.chromium = {
        enable = true;
        package = cfg.package;

        # https://stackoverflow.com/questions/69363637/how-to-write-argument-for-chrome-chromiums-enable-features-flag
        #?? https://source.chromium.org/chromium/chromium/src/+/main:chrome/browser/about_flags.cc
        commandLineArgs = let
          features = concatStringsSep "," [
            "FluentOverlayScrollbar"

            # https://wiki.archlinux.org/title/Chromium#Touchpad_Gestures_for_Navigation
            "TouchpadOverscrollHistoryNavigation"
          ];
        in
          [
            "--enable-features=${features}"
          ]
          ++ optionals (cfg.package.pname == "brave") [
            "--password-store=auto" # Fix secrets defaulting to kwallet
          ];
      };
    };
  };
}
