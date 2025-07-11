#! /usr/bin/env bash

# Match prefixed keyword followed by space
case "$1" in
  'a '*)
    label="Amazon"
    icon="amazon"
    url="https://www.amazon.com/s?k="
    query="${1:2}"
    ;;
  'ai '*)
    label="Open WebUI"
    icon="system-search"
    url="https://ai.bjork.tech/?temporary-chat=true&q="
    query="${1:3}"
    ;;
  'aw '*)
    label="ArchWiki"
    icon="distributor-logo-archlinux"
    url="https://wiki.archlinux.org/index.php?search="
    query="${1:3}"
    ;;
  'b '*)
    label="Brave"
    icon="brave-browser"
    url="https://search.brave.com/search?q="
    query="${1:2}"
    ;;
  'd '*)
    label="DuckDuckGo"
    icon="duckduckgo"
    url="https://duckduckgo.com/?q="
    query="${1:2}"
    ;;
  'dh '*)
    label="Docker Hub"
    icon="docker-desktop"
    url="https://hub.docker.com/search?q="
    query="${1:3}"
    ;;
  'e '*)
    label="e621"
    icon="amarok"
    url="https://e621.net/posts?tags="
    query="${1:2}"
    ;;
  'ei '*)
    label="Element Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/element-hq/element-web/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:3}"
    ;;
  'f '*)
    label="Forums"
    icon="plasma-search"
    url="https://kagi.com/search?l=3&q="
    query="${1:2}"
    ;;
  'fh '*)
    label="Flathub"
    icon="application-vnd.flatpak"
    url="https://flathub.org/apps/search?q="
    query="${1:3}"
    ;;
  'g '*)
    label="Google"
    icon="google"
    url="https://www.google.com/search?q="
    query="${1:2}"
    ;;
  'gf '*)
    label="Google Fonts"
    icon="google"
    url="https://fonts.google.com/?query="
    query="${1:3}"
    ;;
  'gh '*)
    label="GitHub"
    icon="github"
    url="https://github.com/search?q="
    query="${1:3}"
    ;;
  'hi '*)
    label="Home Manager Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/nix-community/home-manager/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:3}"
    ;;
  'ho '*)
    label="Home Manager Options"
    icon="home"
    url="https://home-manager-options.extranix.com/?release=master&query="
    query="${1:3}"
    ;;
  'hyi '*)
    label="Hyprland Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/hyprwm/Hyprland/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:4}"
    ;;
  'i '*)
    label="Images"
    icon="plasma-search"
    url="https://kagi.com/images?q="
    query="${1:2}"
    ;;
  'ii '*)
    label="i3 Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/i3/i3/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:3}"
    ;;
  'k '*)
    label="Kagi"
    icon="plasma-search"
    url="https://kagi.com/search?q="
    query="${1:2}"
    ;;
  'l '*)
    label="Lutris"
    icon="lutris"
    url="https://lutris.net/games?q="
    query="${1:2}"
    ;;
  'li '*)
    label="Lix Issues"
    icon="com.github.zren.bugzilla"
    url="https://git.lix.systems/lix-project/lix/issues?state=open&q="
    query="${1:3}"
    ;;
  'm '*)
    label="Maps"
    icon="com.github.zren.bugzilla"
    url="https://www.google.com/maps/place/"
    query="${1:2}"
    ;;
  'mdn '*)
    label="Mozilla Web Docs"
    icon="emblem-web"
    url="https://developer.mozilla.org/en-US/search?q="
    query="${1:4}"
    ;;
  'mno '*)
    label="MyNixOS Options"
    icon="nix-snowflake"
    url="https://mynixos.com/search?q=option+"
    query="${1:4}"
    ;;
  'nd '*)
    label="Nix Dev"
    icon="nix-snowflake"
    url="https://nix.dev/manual/nix/latest?search="
    query="${1:3}"
    ;;
  'nf '*)
    label="NixOS Flakes"
    icon="nix-snowflake"
    url="https://search.nixos.org/flakes?channel=unstable&query="
    query="${1:3}"
    ;;
  'nh '*)
    label="Nix Hub"
    icon="nix-snowflake"
    url="https://www.nixhub.io/search?q="
    query="${1:3}"
    ;;
  'ni '*)
    label="NixOS Nixpkgs Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:3}"
    ;;
  'no '*)
    label="NixOS Options"
    icon="nix-snowflake"
    url="https://search.nixos.org/options?channel=unstable&query="
    query="${1:3}"
    ;;
  'nod '*)
    label="Noogle Dev"
    icon="nix-snowflake"
    url="https://noogle.dev/q?term="
    query="${1:4}"
    ;;
  'np '*)
    label="NixOS Packages"
    icon="nix-snowflake"
    url="https://search.nixos.org/packages?channel=unstable&query="
    query="${1:3}"
    ;;
  'npr '*)
    label="Nix PR"
    icon="nix-snowflake"
    url="https://nixpk.gs/pr-tracker.html?pr="
    query="${1:4}"
    ;;
  'nii '*)
    label="Niri Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/YaLTeR/niri/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:4}"
    ;;
  'nw '*)
    label="NixOS Wiki"
    icon="nix-snowflake"
    url="https://wiki.nixos.org/w/index.php?search="
    query="${1:3}"
    ;;
  'o '*)
    label="Ollama"
    icon="ollama"
    url="https://ollama.com/search?q="
    query="${1:2}"
    ;;
  'p '*)
    label="Piped"
    icon="youtube"
    url="https://piped.bjork.tech/results?search_query="
    query="${1:2}"
    ;;
  'pc '*)
    label="PCGamingWiki"
    icon="computer"
    url="https://www.pcgamingwiki.com/w/index.php?search="
    query="${1:3}"
    ;;
  'pdb '*)
    label="ProtonDB"
    icon="portproton"
    url="https://www.protondb.com/search?q="
    query="${1:4}"
    ;;
  'pip '*)
    label="PyPI"
    icon="python"
    url="https://pypi.org/search/?q="
    query="${1:4}"
    ;;
  'r '*)
    label="Reddit"
    icon="reddit"
    url="https://kagi.com/search?q=site%3Areddit.com+"
    query="${1:2}"
    ;;
  's '*)
    label="SearXNG"
    icon="preferences-system-search"
    url="https://search.bjork.tech/search?q="
    query="${1:2}"
    ;;
  'si '*)
    label="Sway Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/swaywm/sway/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:3}"
    ;;
  'v '*)
    label="Verbatim"
    icon="plasma-search"
    url="https://kagi.com/search?verbatim=1&q="
    query="${1:2}"
    ;;
  'w '*)
    label="Wikipedia"
    icon="wikipedia"
    url="https://en.wikipedia.org/w/index.php?search="
    query="${1:2}"
    ;;
  'wa '*)
    label="Wolfram Alpha"
    icon="wolfram-mathematica"
    url="https://www.wolframalpha.com/input?i="
    query="${1:3}"
    ;;
  'wi '*)
    label="Walker Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/abenz1267/walker/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:3}"
    ;;
  'y '*)
    label="YouTube"
    icon="youtube"
    url="https://www.youtube.com/results?search_query="
    query="${1:2}"
    ;;
  'zi '*)
    label="Zed Issues"
    icon="com.github.zren.bugzilla"
    url="https://github.com/zed-industries/zed/issues?q=is%3Aissue+is%3Aopen+"
    query="${1:3}"
    ;;
  *)
    exit
    # label="Search"
    # icon="globe-symbolic"
    # url="https://search.brave.com/search?q="
    # query="$1"
    ;;
esac

# URL-encode search query
query="$(echo "$query" | jq --raw-input --raw-output @uri)"

# Return JSON list entry
jq << END
  [
    {
      "label": "$label",
      "icon": "$icon",
      "matching": 1,
      "exec": "$(which xdg-open) '$url$query'"
    }
  ]
END
