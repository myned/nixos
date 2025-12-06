{
  # https://wiki.nixos.org/wiki/Flakes
  #!! Inputs do not support most nix features
  # https://github.com/NixOS/nix/issues/4945
  inputs = {
    # https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake.html
    #?? branch = "git+https://<repo>?ref=<branch>"
    #?? commit = "git+https://<repo>?ref=<branch>&rev=<commit>"
    #?? tag = "git+https://<repo>?ref=refs/tags/<tag>"

    ### Standalone
    flake-parts.url = "github:hercules-ci/flake-parts"; # https://github.com/hercules-ci/flake-parts
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.6.0"; # https://github.com/gmodena/nix-flatpak
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # https://github.com/NixOS/nixos-hardware
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # https://github.com/NixOS/nixpkgs/tree/nixos-25.11
    nixpkgs-master.url = "github:NixOS/nixpkgs/master"; # https://github.com/NixOS/nixpkgs
    nixpkgs-myned.url = "github:myned/nixpkgs/master"; # https://github.com/myned/nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # https://github.com/NixOS/nixpkgs/tree/nixos-unstable

    ### Follows
    # https://github.com/ezKEa/aagl-gtk-on-nix
    aagl-gtk-on-nix = {
      url = "github:ezKEa/aagl-gtk-on-nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/ryantm/agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Aylur/ags
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/hercules-ci/arion
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/abenz1267/elephant
    elephant = {
      url = "github:abenz1267/elephant/v2.16.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Lehmanator/fprint-clear
    fprint-clear = {
      url = "github:Lehmanator/fprint-clear";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Jovian-Experiments/Jovian-NixOS
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/YaLTeR/niri
    niri = {
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/sodiboo/niri-flake
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/thiagokokada/nix-alien
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/nix-index-database
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/nix-vscode-extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/nixd
    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/nixGL
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/AshleyYakeley/NixVirt
    nixvirt = {
      url = "github:AshleyYakeley/NixVirt/v0.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/NUR
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/stylix
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/abenz1267/walker
    walker = {
      url = "github:abenz1267/walker/v2.11.3";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };

    # https://github.com/youwen5/zen-browser-flake
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Source code
    # https://github.com/
    # cisco-packettracer8 = {
    #   url = "file:///home/myned/SYNC/linux/config/cisco/CiscoPacketTracer822_amd64_signed.deb";
    #   flake = false;
    # };

    # https://github.com/Eisa01/FreshRSS---Auto-Refresh-Extension
    # freshrss-autorefresh = {
    #   url = "github:Eisa01/FreshRSS---Auto-Refresh-Extension";
    #   flake = false;
    # };

    # https://github.com/cn-tools/cntools_FreshRssExtensions
    # freshrss-cntools = {
    #   url = "github:cn-tools/cntools_FreshRssExtensions";
    #   flake = false;
    # };

    # https://github.com/giventofly/freshrss-comicsinfeed
    # freshrss-comicsinfeed = {
    #   url = "github:giventofly/freshrss-comicsinfeed";
    #   flake = false;
    # };

    # https://github.com/aledeg/xExtension-DateFormat
    # freshrss-dateformat = {
    #   url = "github:aledeg/xExtension-DateFormat";
    #   flake = false;
    # };

    # https://github.com/FreshRSS/Extensions
    # freshrss-extensions = {
    #   url = "github:FreshRSS/Extensions";
    #   flake = false;
    # };

    # https://code.sitosis.com/rudism/freshrss-kagi-summarizer
    # freshrss-kagisummarizer = {
    #   url = "git+https://code.sitosis.com/rudism/freshrss-kagi-summarizer";
    #   flake = false;
    # };

    # https://github.com/kapdap/freshrss-extensions
    # freshrss-kapdap = {
    #   url = "github:kapdap/freshrss-extensions";
    #   flake = false;
    # };

    # https://github.com/kalvn/freshrss-mark-previous-as-read
    # freshrss-markpreviousasread = {
    #   url = "github:kalvn/freshrss-mark-previous-as-read";
    #   flake = false;
    # };

    # https://github.com/Rawa/lifx-cli
    lifx-cli = {
      url = "github:Rawa/lifx-cli";
      flake = false;
    };

    # https://github.com/sonic2kk/steamtinkerlaunch
    # steamtinkerlaunch = {
    #   url = "github:sonic2kk/steamtinkerlaunch";
    #   flake = false;
    # };

    # https://github.com/ErikReider/SwayNotificationCenter
    # swaynotificationcenter = {
    #   url = "github:ErikReider/SwayNotificationCenter?ref=v0.11.0";
    #   flake = false;
    # };

    # https://github.com/rafaelmardojai/thunderbird-gnome-theme
    # thunderbird-gnome-theme = {
    #   url = "github:rafaelmardojai/thunderbird-gnome-theme";
    #   flake = false;
    # };

    # https://fedorapeople.org/groups/virt/virtio-win/
    # virtio-win = {
    #   url = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win.iso";
    #   flake = false;
    # };
  };

  # https://flake.parts/
  # https://wiki.nixos.org/wiki/Flake_Parts
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      # https://flake.parts/options/flake-parts.html#opt-systems
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      # https://flake.parts/options/flake-parts.html#opt-perSystem
      perSystem = {pkgs, ...}: {
        # https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-fmt
        # https://github.com/kamadorueda/alejandra/blob/main/STYLE.md
        formatter = pkgs.alejandra;
      };

      # https://flake.parts/options/flake-parts.html#opt-flake
      flake = let
        #!! Avoid globally importing modules that are not guarded by .enable
        # https://github.com/NixOS/nixpkgs/issues/137168
        commonModules = [
          ./options
          ./configuration.nix
        ];
      in {
        # NixOS systems
        nixosConfigurations = let
          nixos = system: modules:
            inputs.nixpkgs.lib.nixosSystem {
              inherit system;
              modules = commonModules ++ modules;

              # TODO: Use inline modules instead of specialArgs
              # https://jade.fyi/blog/flakes-arent-real#nixos-modules
              specialArgs = {inherit inputs;};
            };
        in {
          myeck = nixos "x86_64-linux" [./profiles/deck ./machines/myeck];
          myeye = nixos "x86_64-linux" [./profiles/compute ./machines/myeye];
          mynix = nixos "x86_64-linux" [./profiles/desktop ./machines/mynix];
          myore = nixos "x86_64-linux" [./profiles/core ./machines/myore];
          myork = nixos "x86_64-linux" [./profiles/laptop ./machines/myork];
          myosh = nixos "x86_64-linux" [./profiles/server ./machines/myosh];
          mypi3 = nixos "aarch64-linux" [./profiles/sbc ./machines/mypi3];
        };

        # Standalone home-manager configurations
        # https://nix-community.github.io/home-manager/#sec-upgrade-release-understanding-flake
        homeConfigurations = let
          home = system: modules:
            inputs.home-manager.lib.homeManagerConfiguration {
              modules = commonModules ++ modules;
              pkgs = inputs.nixpkgs.legacyPackages.${system};
            };
        in {
          myned = home "x86_64-linux" [];
        };
      };
    };
}
