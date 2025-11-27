#!! Generate flake.nix
# https://github.com/jorsn/flakegen
# HACK: Remove flakegen if nix expressions are officially implemented
# https://github.com/NixOS/nix/issues/3966
#?? rm flake.nix
#?? nix flake init -t github:myned/flakegen
#?? nix run .#genflake flake.nix
#?? git add .
{
  # https://wiki.nixos.org/wiki/Flakes
  # https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake.html
  #?? branch = "git+https://<repo>?ref=<branch>"
  #?? commit = "git+https://<repo>?ref=<branch>&rev=<commit>"
  #?? tag = "git+https://<repo>?ref=refs/tags/<tag>"
  inputs = let
    stable = "25.05";
    unstable = "25.11";
  in
    builtins.mapAttrs (name: value: {url = value;}) {
      ### Standalone
      flake-parts = "github:hercules-ci/flake-parts";
      nix-flatpak = "github:gmodena/nix-flatpak?ref=v0.6.0";
      nixos-hardware = "github:NixOS/nixos-hardware";
      nixpkgs-master = "github:NixOS/nixpkgs/master";
      nixpkgs-myned = "github:myned/nixpkgs/master";
      nixpkgs-stable = "github:NixOS/nixpkgs/nixos-${stable}";
      nixpkgs-unstable = "github:NixOS/nixpkgs/nixos-${unstable}";
    }
    // builtins.mapAttrs (name: value: {url = value;} // {inputs.nixpkgs.follows = "nixpkgs-stable";}) {
      ### Stable
      aagl-gtk-on-nix-stable = "github:ezKEa/aagl-gtk-on-nix/release-${stable}";
      home-manager-stable = "github:nix-community/home-manager/release-${stable}";
      nix-index-database-stable = "github:nix-community/nix-index-database";
      nixgl-stable = "github:nix-community/nixGL";
      nur-stable = "github:nix-community/NUR";
      stylix-stable = "github:nix-community/stylix/release-${stable}";
    }
    // builtins.mapAttrs (name: value: {url = value;} // {inputs.nixpkgs.follows = "nixpkgs-unstable";}) {
      ### Unstable
      aagl-gtk-on-nix-unstable = "github:ezKEa/aagl-gtk-on-nix/release-${unstable}";
      agenix = "github:ryantm/agenix";
      ags = "github:Aylur/ags";
      arion = "github:hercules-ci/arion";
      disko = "github:nix-community/disko";
      home-manager-unstable = "github:nix-community/home-manager/release-${unstable}";
      jovian-nixos = "github:Jovian-Experiments/Jovian-NixOS";
      niri = "github:YaLTeR/niri";
      niri-flake = "github:sodiboo/niri-flake";
      nix-alien = "github:thiagokokada/nix-alien";
      nix-index-database-unstable = "github:nix-community/nix-index-database";
      nix-vscode-extensions = "github:nix-community/nix-vscode-extensions";
      nixd = "github:nix-community/nixd";
      nixgl-unstable = "github:nix-community/nixGL";
      nixvirt = "github:AshleyYakeley/NixVirt/v0.6.0";
      nur-unstable = "github:nix-community/NUR";
      stylix-unstable = "github:nix-community/stylix/release-${unstable}";
      zen-browser = "github:youwen5/zen-browser-flake";
    }
    // builtins.mapAttrs (name: value: {
      url = value;
      flake = false;
    }) {
      ### Source code
      #// cisco-packettracer8 = "file:///home/myned/SYNC/linux/config/cisco/CiscoPacketTracer822_amd64_signed.deb";
      #// freshrss-autorefresh = "github:Eisa01/FreshRSS---Auto-Refresh-Extension";
      #// freshrss-cntools = "github:cn-tools/cntools_FreshRssExtensions";
      #// freshrss-comicsinfeed = "github:giventofly/freshrss-comicsinfeed";
      #// freshrss-dateformat = "github:aledeg/xExtension-DateFormat";
      #// freshrss-extensions = "github:FreshRSS/Extensions";
      #// freshrss-kagisummarizer = "git+https://code.sitosis.com/rudism/freshrss-kagi-summarizer";
      #// freshrss-kapdap = "github:kapdap/freshrss-extensions";
      #// freshrss-markpreviousasread = "github:kalvn/freshrss-mark-previous-as-read";
      lifx-cli = "github:Rawa/lifx-cli";
      #// steamtinkerlaunch = "github:sonic2kk/steamtinkerlaunch";
      #// swaynotificationcenter = "github:ErikReider/SwayNotificationCenter?ref=v0.11.0";
      #// thunderbird-gnome-theme = "github:rafaelmardojai/thunderbird-gnome-theme";
      #// virtio-win = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win.iso";
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
        globalModules = branch: [
          ./options
          ./configuration.nix

          #!! Avoid globally importing modules that are not guarded by .enable
          # https://github.com/NixOS/nixpkgs/issues/137168
          {
            home-manager.sharedModules = [
              inputs."nix-index-database-${branch}".homeModules.nix-index
              inputs.ags.homeManagerModules.default
              inputs.nix-flatpak.homeManagerModules.nix-flatpak

              # TODO: Use official module when supported
              # https://github.com/nix-community/home-manager/blob/master/modules/programs/floorp.nix
              (let
                modulePath = ["programs" "zen-browser"];
                mkFirefoxModule = import "${inputs."home-manager-${branch}"}/modules/programs/firefox/mkFirefoxModule.nix";
              in
                mkFirefoxModule {
                  inherit modulePath;
                  name = "Zen";
                  wrappedPackageName = "zen-browser";
                  unwrappedPackageName = "zen-browser-unwrapped";
                  visible = true;

                  platforms.linux = {
                    configPath = ".zen";
                    vendorPath = ".mozilla";
                  };

                  platforms.darwin = {
                    configPath = "Library/Application Support/Zen";
                    vendorPath = "Library/Application Support/Mozilla";
                  };
                })
            ];

            # Branch-specific overlays
            nixpkgs.overlays = [
              inputs."nixgl-${branch}".overlays.default
            ];
          }
        ];
      in {
        # NixOS systems with global imports
        #!! There is no default nixpkgs, inputs.nixpkgs-<branch> must exist
        nixosConfigurations = let
          nixos = branch: system: modules:
            inputs."nixpkgs-${branch}".lib.nixosSystem {
              inherit system;

              # TODO: Use inline modules instead of specialArgs
              # https://jade.fyi/blog/flakes-arent-real#nixos-modules
              specialArgs = {inherit inputs;};

              modules =
                modules
                ++ (globalModules branch)
                ++ [
                  {
                    imports = [
                      inputs."aagl-gtk-on-nix-${branch}".nixosModules.default
                      inputs."home-manager-${branch}".nixosModules.home-manager
                      inputs."nix-index-database-${branch}".nixosModules.nix-index
                      inputs."nur-${branch}".modules.nixos.default
                      inputs."stylix-${branch}".nixosModules.stylix
                      inputs.agenix.nixosModules.default
                      inputs.arion.nixosModules.arion
                      inputs.disko.nixosModules.disko
                      inputs.niri-flake.nixosModules.niri
                      inputs.nixvirt.nixosModules.default
                    ];
                  }
                ];
            };
        in {
          ### Stable
          myeye = nixos "stable" "x86_64-linux" [./profiles/compute ./machines/myeye];
          myore = nixos "stable" "x86_64-linux" [./profiles/core ./machines/myore];
          myosh = nixos "stable" "x86_64-linux" [./profiles/server ./machines/myosh];
          mypi3 = nixos "stable" "aarch64-linux" [./profiles/sbc ./machines/mypi3];

          ### Unstable
          myeck = nixos "unstable" "x86_64-linux" [./profiles/deck ./machines/myeck];
          mynix = nixos "unstable" "x86_64-linux" [./profiles/desktop ./machines/mynix];
          myork = nixos "unstable" "x86_64-linux" [./profiles/laptop ./machines/myork];
        };

        # Standalone home-manager configurations
        # https://nix-community.github.io/home-manager/#sec-upgrade-release-understanding-flake
        homeConfigurations = let
          home = branch: system: modules:
            inputs."home-manager-${branch}".lib.homeManagerConfiguration {
              modules = modules ++ (globalModules branch);
              pkgs = inputs."nixpkgs-${branch}".legacyPackages.${system};
            };
        in {
          myned = home "stable" "x86_64-linux" [];
        };
      };
    };
}
