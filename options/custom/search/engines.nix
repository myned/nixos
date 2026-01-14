{
  config,
  lib,
  ...
}:
with lib; {
  options.custom.search.engines = mkOption {
    description = "Submodules of search engines";

    example = {
      google = {
        title = "Google";
        shortcut = "g";
        iconUrl = "https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico";
        searchUrl = "https://google.com/search?q=%s";
        suggestUrl = "https://www.google.com/complete/search?q=%s";
      };
    };

    type = with types;
      attrsOf (submodule ({name, ...}: {
        options = {
          name = mkOption {
            description = "Name of the search engine";
            default = name;
            example = "google";
            type = str;
          };

          title = mkOption {
            description = "Title of the search engine";
            default = "";
            example = "Google";
            type = str;
          };

          shortcut = mkOption {
            description = "Shortcut keyword of the search engine";
            default = "";
            example = "g";
            type = str;
          };

          iconUrl = mkOption {
            description = "Icon URL of the search engine";
            default = "";
            example = "https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico";
            type = str;
          };

          searchUrl = mkOption {
            description = "Search URL of the search engine";
            default = "";
            example = "https://www.google.com/search?q=%s";
            type = str;
          };

          suggestUrl = mkOption {
            description = "Suggest URL of the search engine";
            default = "";
            example = "https://www.google.com/complete/search?q=%s";
            type = str;
          };
        };
      }));
  };

  config = {
    custom.search.engines = {
      amazon = {
        title = "Amazon";
        shortcut = "az";
        iconUrl = "https://www.amazon.com/favicon.ico";
        searchUrl = "https://www.amazon.com/s?k=%s";
      };

      ansible-galaxy = {
        title = "Ansible Galaxy";
        shortcut = "ag";
        iconUrl = "https://galaxy.ansible.com/favicon.ico";
        searchUrl = "https://galaxy.ansible.com/ui/standalone/roles/?page=1&page_size=100&sort=-download_count&keywords=%s";
      };

      arch-wiki = {
        title = "Arch Wiki";
        shortcut = "aw";
        iconUrl = "https://wiki.archlinux.org/favicon.ico";
        searchUrl = "https://wiki.archlinux.org/index.php?search=%s";
      };

      brave = {
        title = "Brave";
        shortcut = "b";
        iconUrl = "https://cdn.search.brave.com/serp/v2/_app/immutable/assets/favicon.c09fe1a1.ico";
        searchUrl = "https://search.brave.com/search?q=%s";
      };

      brave-summary = {
        title = "Brave Summary";
        shortcut = "bs";
        iconUrl = "https://cdn.search.brave.com/serp/v2/_app/immutable/assets/favicon.c09fe1a1.ico";
        searchUrl = "https://search.brave.com/search?summary=1&q=%s";
      };

      chrome-extensions = {
        title = "Chrome Extensions";
        shortcut = "cex";
        iconUrl = "https://ssl.gstatic.com/chrome/webstore/images/icon_48px.png";
        searchUrl = "https://chromewebstore.google.com/search/";
      };

      docker-hub = {
        title = "Docker Hub";
        shortcut = "dh";
        iconUrl = "https://hub.docker.com/favicon.ico";
        searchUrl = "https://hub.docker.com/search?q=%s";
      };

      duckduckgo = {
        title = "DuckDuckGo";
        shortcut = "d";
        iconUrl = "https://duckduckgo.com/favicon.ico";
        searchUrl = "https://duckduckgo.com/?q=%s";
      };

      e621 = {
        title = "e621";
        shortcut = "e";
        iconUrl = "https://e621.net/favicon.ico";
        searchUrl = "https://e621.net/posts?tags=%s";
      };

      element-issues = {
        title = "Element Issues";
        shortcut = "ei";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/element-hq/element-web/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      firefox-extensions = {
        title = "Firefox Extensions";
        shortcut = "fex";
        iconUrl = "https://addons.mozilla.org/favicon.ico";
        searchUrl = "https://addons.mozilla.org/en-US/firefox/search/?q=%s";
      };

      flathub = {
        title = "Flathub";
        shortcut = "fh";
        iconUrl = "https://flathub.org/favicon.png";
        searchUrl = "https://flathub.org/apps/search?q=%s";
      };

      github = {
        title = "GitHub";
        shortcut = "gh";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/search?q=%s";
      };

      google = {
        title = "Google";
        shortcut = "g";
        iconUrl = "https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico";
        searchUrl = "https://google.com/search?q=%s";
        suggestUrl = "https://google.com/complete/search?&q=%s";
      };

      google-ai = {
        title = "Google AI Mode";
        shortcut = "ga";
        iconUrl = "https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico";
        searchUrl = "https://google.com/aimode?q=%s";
      };

      google-fonts = {
        title = "Google Fonts";
        shortcut = "gf";
        iconUrl = "https://www.gstatic.com/images/icons/material/apps/fonts/1x/catalog/v5/favicon.svg";
        searchUrl = "https://fonts.google.com/?query=%s";
      };

      google-maps = {
        title = "Google Maps";
        shortcut = "gm";
        iconUrl = "https://www.google.com/images/branding/product/ico/maps15_bnuw3a_32dp.ico";
        searchUrl = "https://www.google.com/maps/search/%s";
      };

      homemanager-issues = {
        title = "Home Manager Issues";
        shortcut = "hi";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/nix-community/home-manager/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      homemanager-options = {
        title = "Home Manager Options";
        shortcut = "ho";
        iconUrl = "https://home-manager-options.extranix.com/images/favicon.png";
        searchUrl = "https://home-manager-options.extranix.com/?release=master&query=%s";
      };

      hyprland-issues = {
        title = "Hyprland Issues";
        shortcut = "hyi";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/hyprwm/Hyprland/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      i3-issues = {
        title = "i3 Issues";
        shortcut = "i3i";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/i3/i3/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      kagi = {
        title = "Kagi";
        shortcut = "k";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/search?q=%s";
        suggestUrl = "https://kagi.com/api/autosuggest?q=%s";
      };

      # https://help.kagi.com/kagi/ai/assistant.html#url-parameters
      kagi-assistant = {
        title = "Kagi Assistant";
        shortcut = "ka";
        iconUrl = "https://kagi.com/favicon-assistant-32x32.png";
        searchUrl = "https://kagi.com/assistant?q=%s";
      };

      kagi-assistant-code = {
        title = "Kagi Assistant Code";
        shortcut = "kac";
        iconUrl = "https://kagi.com/favicon-assistant-32x32.png";
        searchUrl = "https://kagi.com/search?q=%21code+%s";
      };

      kagi-assistant-chef = {
        title = "Kagi Assistant Chef";
        shortcut = "kah";
        iconUrl = "https://kagi.com/favicon-assistant-32x32.png";
        searchUrl = "https://kagi.com/search?q=%21chef+%s";
      };

      kagi-assistant-news = {
        title = "Kagi Assistant News";
        shortcut = "kan";
        iconUrl = "https://kagi.com/favicon-assistant-32x32.png";
        searchUrl = "https://kagi.com/search?q=%21news+%s";
      };

      kagi-assistant-quick = {
        title = "Kagi Assistant Quick";
        shortcut = "kaq";
        iconUrl = "https://kagi.com/favicon-assistant-32x32.png";
        searchUrl = "https://kagi.com/search?q=%21ki+%s";
      };

      kagi-assistant-research = {
        title = "Kagi Assistant Research";
        shortcut = "kar";
        iconUrl = "https://kagi.com/favicon-assistant-32x32.png";
        searchUrl = "https://kagi.com/search?q=%21research+%s";
      };

      kagi-assistant-write = {
        title = "Kagi Assistant Write";
        shortcut = "kaw";
        iconUrl = "https://kagi.com/favicon-assistant-32x32.png";
        searchUrl = "https://kagi.com/search?q=%21write+%s";
      };

      kagi-fastgpt = {
        title = "Kagi FastGPT";
        shortcut = "kg";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/fastgpt?query=%s";
      };

      kagi-forums = {
        title = "Kagi Forums";
        shortcut = "kf";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/search?l=0&q=%s";
      };

      kagi-images = {
        title = "Kagi Images";
        shortcut = "ki";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/images?q=%s";
      };

      kagi-maps = {
        title = "Kagi Maps";
        shortcut = "km";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/maps/search?q=%s";
      };

      kagi-news = {
        title = "Kagi News";
        shortcut = "kn";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/news?q=%s";
      };

      kagi-podcasts = {
        title = "Kagi Podcasts";
        shortcut = "kp";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/podcasts?q=%s";
      };

      kagi-summarizer = {
        title = "Kagi Summarizer";
        shortcut = "kz";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/summarizer?summary=takeaway#%s";
      };

      kagi-summary = {
        title = "Kagi Summary";
        shortcut = "ks";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/search?q=%s%3F";
      };

      kagi-translate = {
        title = "Kagi Translate";
        shortcut = "kt";
        iconUrl = "https://translate.kagi.com/icons/favicon.ico";
        searchUrl = "https://translate.kagi.com/?from=auto&to=en&text=%s";
      };

      kagi-translate-dictionary = {
        title = "Kagi Translate Dictionary";
        shortcut = "ktd";
        iconUrl = "https://translate.kagi.com/icons/favicon.ico";
        searchUrl = "https://translate.kagi.com/dictionary?from=auto&word=%s";
      };

      kagi-translate-proofread = {
        title = "Kagi Translate Proofread";
        shortcut = "ktp";
        iconUrl = "https://translate.kagi.com/icons/favicon.ico";
        searchUrl = "https://translate.kagi.com/proofread?from=auto&text=%s";
      };

      kagi-translate-website = {
        title = "Kagi Translate Website";
        shortcut = "ktw";
        iconUrl = "https://translate.kagi.com/icons/favicon.ico";
        searchUrl = "https://translate.kagi.com/%s";
      };

      kagi-verbatim = {
        title = "Kagi Verbatim";
        shortcut = "kvb";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/search?verbatim=1&q=%s";
      };

      kagi-videos = {
        title = "Kagi Videos";
        shortcut = "kv";
        iconUrl = "https://kagi.com/asset/v2/favicon-32x32.png";
        searchUrl = "https://kagi.com/videos?q=%s";
      };

      lix-issues = {
        title = "Lix Issues";
        shortcut = "li";
        iconUrl = "https://git.lix.systems/assets/img/favicon.png";
        searchUrl = "https://git.lix.systems/lix-project/lix/issues?state=open&q=%s";
      };

      lutris = {
        title = "Lutris";
        shortcut = "l";
        iconUrl = "https://lutris.net/favicon.ico";
        searchUrl = "https://lutris.net/games?q=%s";
      };

      mdn-web-docs = {
        title = "MDN Web Docs";
        shortcut = "mdn";
        iconUrl = "https://developer.mozilla.org/favicon-48x48.cbbd161b.png";
        searchUrl = "https://developer.mozilla.org/en-US/search?q=%s";
      };

      mynixos-options = {
        title = "MyNixOS Options";
        shortcut = "mno";
        iconUrl = "https://mynixos.com/favicon.ico";
        searchUrl = "https://mynixos.com/search?q=option+%s";
      };

      niri-issues = {
        title = "Niri Issues";
        shortcut = "nii";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/YaLTeR/niri/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      nix-dev = {
        title = "Nix Dev";
        shortcut = "nd";
        iconUrl = "https://nix.dev/manual/nix/latest/favicon.png";
        searchUrl = "https://nix.dev/manual/nix/latest?search=%s";
      };

      nix-hub = {
        title = "Nix Hub";
        shortcut = "nh";
        iconUrl = "https://www.nixhub.io/favicon.ico";
        searchUrl = "https://www.nixhub.io/search?q=%s";
      };

      nixos-flakes = {
        title = "NixOS Flakes";
        shortcut = "nf";
        iconUrl = "https://nixos.org/favicon.png";
        searchUrl = "https://search.nixos.org/flakes?channel=unstable&query=%s";
      };

      nixos-options = {
        title = "NixOS Options";
        shortcut = "no";
        iconUrl = "https://nixos.org/favicon.png";
        searchUrl = "https://search.nixos.org/options?channel=unstable&query=%s";
      };

      nixos-packages = {
        title = "NixOS Packages";
        shortcut = "np";
        iconUrl = "https://nixos.org/favicon.png";
        searchUrl = "https://search.nixos.org/packages?channel=unstable&query=%s";
      };

      nixpkgs-issues = {
        title = "Nixpkgs Issues";
        shortcut = "ni";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      nixpkgs-pr = {
        title = "Nixpkgs PR";
        shortcut = "npr";
        searchUrl = "https://nixpk.gs/pr-tracker.html?pr=%s";
      };

      nixos-wiki = {
        title = "NixOS Wiki";
        shortcut = "nw";
        iconUrl = "https://wiki.nixos.org/favicon.ico";
        searchUrl = "https://wiki.nixos.org/w/index.php?search=%s";
      };

      noogle-dev = {
        title = "Noogle Dev";
        shortcut = "nod";
        iconUrl = "https://noogle.dev/favicon.png";
        searchUrl = "https://noogle.dev/q?term=%s";
      };

      ollama = {
        title = "Ollama";
        shortcut = "o";
        iconUrl = "https://ollama.com/public/icon-64x64.png";
        searchUrl = "https://ollama.com/search?q=%s";
      };

      open-webui = {
        title = "Open WebUI";
        shortcut = "ow";
        iconUrl = "https://ai.${config.custom.domain}/static/favicon.ico";
        searchUrl = "https://ai.${config.custom.domain}/?temporary-chat=true&q=%s";
      };

      pcgamingwiki = {
        title = "PCGamingWiki";
        shortcut = "pc";
        iconUrl = "https://static.pcgamingwiki.com/favicons/pcgamingwiki.png";
        searchUrl = "https://www.pcgamingwiki.com/w/index.php?search=%s";
      };

      perplexity = {
        title = "Perplexity";
        shortcut = "p";
        iconUrl = "https://www.perplexity.ai/favicon.svg";
        searchUrl = "https://perplexity.ai/?q=%s";
      };

      piped = {
        title = "Piped";
        shortcut = "yp";
        iconUrl = "https://piped.${config.custom.domain}/favicon.ico";
        searchUrl = "https://piped.${config.custom.domain}/results?search_query=%s";
      };

      protondb = {
        title = "ProtonDB";
        shortcut = "pdb";
        iconUrl = "https://www.protondb.com/sites/protondb/images/favicon.ico";
        searchUrl = "https://www.protondb.com/search?q=%s";
      };

      pypi = {
        title = "PyPI";
        shortcut = "pip";
        iconUrl = "https://pypi.org/static/images/favicon.35549fe8.ico";
        searchUrl = "https://pypi.org/search/?q=%s";
      };

      reddit = {
        title = "Reddit";
        shortcut = "r";
        iconUrl = "https://www.redditstatic.com/shreddit/assets/favicon/192x192.png";
        searchUrl = "${config.custom.search.default.searchUrl}+site%3Areddit.com";
      };

      searxng = {
        title = "SearXNG";
        shortcut = "s";
        iconUrl = "https://search.${config.custom.domain}/static/themes/simple/img/favicon.png";
        searchUrl = "https://search.${config.custom.domain}/search?q=%s";
      };

      steamgriddb = {
        title = "SteamGridDB";
        shortcut = "sgdb";
        iconUrl = "https://www.steamgriddb.com/static/favicon/16.png";
        searchUrl = "https://www.steamgriddb.com/search/grids?term=%s";
      };

      sway-issues = {
        title = "Sway Issues";
        shortcut = "si";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/swaywm/sway/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      walker-issues = {
        title = "Walker Issues";
        shortcut = "wi";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/abenz1267/walker/issues?q=is%3Aissue+is%3Aopen+%s";
      };

      wikipedia = {
        title = "Wikipedia";
        shortcut = "w";
        iconUrl = "https://www.wikipedia.org/static/favicon/wikipedia.ico";
        searchUrl = "https://www.wikipedia.org/w/index.php?search=%s";
      };

      wolfram-alpha = {
        title = "Wolfram Alpha";
        shortcut = "wa";
        iconUrl = "https://www.wolframalpha.com/_next/static/images/favicon_1zbE9hjk.ico";
        searchUrl = "https://www.wolframalpha.com/input?i=%s";
      };

      youtube = {
        title = "YouTube";
        shortcut = "y";
        iconUrl = "https://www.youtube.com/s/desktop/f8c8418d/img/favicon.ico";
        searchUrl = "https://www.youtube.com/results?search_query=%s";
      };

      zed-issues = {
        title = "Zed Issues";
        shortcut = "zi";
        iconUrl = "https://github.com/favicon.ico";
        searchUrl = "https://github.com/zed-industries/zed/issues?q=is%3Aissue+is%3Aopen+%s";
      };
    };
  };
}
