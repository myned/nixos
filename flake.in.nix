#!! Generate flake.nix
# https://github.com/jorsn/flakegen
#?? rm flake.nix
#?? nix flake init -t github:jorsn/flakegen
#?? git add .
#?? nix run .#genflake flake.nix
# TODO: Remove flakegen hook when nix expressions are officially implemented
# https://github.com/NixOS/nix/issues/3966
{
  # https://wiki.nixos.org/wiki/Flakes
  # https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake.html
  inputs = let
    flake = url: {inherit url;};
    follows = branch: {inputs.nixpkgs.follows = "nixpkgs-${branch}";};

    source = url: {
      inherit url;
      flake = false;
    };
  in {
    #?? branch = "git+https://REPO?ref=BRANCH"
    #?? commit = "git+https://REPO?ref=BRANCH&rev=COMMIT"
    #?? tag = "git+https://REPO?ref=refs/tags/TAG"

    ### Standalone
    flake-parts = flake "github:hercules-ci/flake-parts";
    nixos-hardware = flake "github:NixOS/nixos-hardware";

    ### Stable
    nixpkgs-stable = flake "github:NixOS/nixpkgs/nixos-25.05";

    aagl-gtk-on-nix-stable = flake "github:ezKEa/aagl-gtk-on-nix/release-25.05" // follows "stable";
    home-manager-stable = flake "github:nix-community/home-manager/release-25.05" // follows "stable";
    nix-index-database-stable = flake "github:nix-community/nix-index-database" // follows "stable";
    nixgl-stable = flake "github:nix-community/nixGL" // follows "stable";
    nur-stable = flake "github:nix-community/NUR" // follows "stable";
    stylix-stable = flake "github:danth/stylix/release-25.05" // follows "stable";

    ### Unstable
    nixpkgs-unstable = flake "github:NixOS/nixpkgs/nixos-unstable";

    aagl-gtk-on-nix-unstable = flake "github:ezKEa/aagl-gtk-on-nix" // follows "unstable";
    agenix = flake "github:ryantm/agenix" // follows "unstable";
    ags = flake "github:Aylur/ags" // follows "unstable";
    arion = flake "github:hercules-ci/arion" // follows "unstable";
    #// bitwarden-menu = flake "github:firecat53/bitwarden-menu" // follows "unstable";
    #// compose2nix = flake "github:aksiksi/compose2nix" // follows "unstable";
    #// conduwuit = flake "github:Myned/conduwuit" // follows "unstable";
    disko = flake "github:nix-community/disko" // follows "unstable";
    fw-fanctrl = flake "github:TamtamHero/fw-fanctrl/packaging/nix" // follows "unstable";
    home-manager-unstable = flake "github:nix-community/home-manager" // follows "unstable";
    hypridle = flake "github:hyprwm/hypridle" // follows "unstable";
    #// hyprland = flake "github:hyprwm/Hyprland?ref=v0.45.2" // follows "unstable";
    #// hyprland-contrib = flake "github:hyprwm/contrib" // follows "unstable";
    #// hyprland-plugins = flake "github:hyprwm/hyprland-plugins" // follows "unstable" // follows "hyprland";
    hyprlock = flake "github:hyprwm/hyprlock" // follows "unstable";
    #// hyprpaper = flake "github:hyprwm/hyprpaper" // follows "unstable";
    hyprpicker = flake "github:hyprwm/hyprpicker" // follows "unstable";
    jovian-nixos = flake "github:Jovian-Experiments/Jovian-NixOS" // follows "unstable";
    niri = flake "github:YaLTeR/niri" // follows "unstable";
    niri-flake = flake "github:sodiboo/niri-flake" // follows "unstable";
    nix-alien = flake "github:thiagokokada/nix-alien" // follows "unstable";
    nix-flatpak = flake "github:gmodena/nix-flatpak?ref=v0.5.1";
    nix-index-database-unstable = flake "github:nix-community/nix-index-database" // follows "unstable";
    nix-vscode-extensions = flake "github:nix-community/nix-vscode-extensions" // follows "unstable";
    nixd = flake "github:nix-community/nixd" // follows "unstable";
    nixgl-unstable = flake "github:nix-community/nixGL" // follows "unstable";
    nixvirt = flake "github:AshleyYakeley/NixVirt/v0.6.0" // follows "unstable";
    nur-unstable = flake "github:nix-community/NUR" // follows "unstable";
    stylix-unstable = flake "github:danth/stylix" // follows "unstable";
    #// walker = flake "github:abenz1267/walker?ref=v0.12.8" // follows "unstable";
    zen-browser = flake "github:youwen5/zen-browser-flake" // follows "unstable";

    ### Branches
    nixpkgs-master = flake "github:NixOS/nixpkgs/master";
    nixpkgs-myned = flake "github:myned/nixpkgs/master";
    nixpkgs-gitbutler = flake "github:25huizengek1/nixpkgs/gitbutler";

    ### Source code
    #// cisco-packettracer8 = source "file:///home/myned/SYNC/linux/config/cisco/CiscoPacketTracer822_amd64_signed.deb";
    #// freshrss-autorefresh = source "github:Eisa01/FreshRSS---Auto-Refresh-Extension";
    #// freshrss-cntools = source "github:cn-tools/cntools_FreshRssExtensions";
    #// freshrss-comicsinfeed = source "github:giventofly/freshrss-comicsinfeed";
    #// freshrss-dateformat = source "github:aledeg/xExtension-DateFormat";
    #// freshrss-extensions = source "github:FreshRSS/Extensions";
    #// freshrss-kagisummarizer = source "git+https://code.sitosis.com/rudism/freshrss-kagi-summarizer";
    #// freshrss-kapdap = source "github:kapdap/freshrss-extensions";
    #// freshrss-markpreviousasread = source "github:kalvn/freshrss-mark-previous-as-read";
    lifx-cli = source "github:Rawa/lifx-cli";
    #// steamtinkerlaunch = source "github:sonic2kk/steamtinkerlaunch";
    #// swaynotificationcenter = source "github:ErikReider/SwayNotificationCenter?ref=v0.11.0";
    #// thunderbird-gnome-theme = source "github:rafaelmardojai/thunderbird-gnome-theme";
    virtio-win = source "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win.iso";
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
                      inputs.fw-fanctrl.nixosModules.default
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
