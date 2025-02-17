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
    follows = input: {inputs.${input}.follows = input;};
    stable = input: {inputs.${input}.follows = "${input}-stable";};
    unstable = input: {inputs.${input}.follows = "${input}-unstable";};

    source = url: {
      inherit url;
      flake = false;
    };
  in {
    #?? branch = "git+https://REPO?ref=BRANCH"
    #?? commit = "git+https://REPO?ref=BRANCH&rev=COMMIT"
    #?? tag = "git+https://REPO?ref=refs/tags/TAG"

    ### Standalone
    nixos-hardware = flake "github:NixOS/nixos-hardware";

    ### Stable
    nixpkgs-stable = flake "github:NixOS/nixpkgs/nixos-24.11";

    aagl-gtk-on-nix-stable = flake "github:ezKEa/aagl-gtk-on-nix/release-24.11" // stable "nixpkgs";
    home-manager-stable = flake "github:nix-community/home-manager/release-24.11" // stable "nixpkgs";
    nix-index-database-stable = flake "github:nix-community/nix-index-database" // stable "nixpkgs";
    nixgl-stable = flake "github:nix-community/nixGL" // stable "nixpkgs";
    nur-stable = flake "github:nix-community/NUR" // stable "nixpkgs";
    stylix-stable = flake "github:danth/stylix/release-24.11" // stable "nixpkgs";

    ### Unstable
    nixpkgs-unstable = flake "github:NixOS/nixpkgs/nixos-unstable";

    aagl-gtk-on-nix-unstable = flake "github:ezKEa/aagl-gtk-on-nix" // unstable "nixpkgs";
    agenix = flake "github:ryantm/agenix" // unstable "nixpkgs";
    ags = flake "github:Aylur/ags" // unstable "nixpkgs";
    anyrun = flake "github:Kirottu/anyrun" // unstable "nixpkgs";
    arion = flake "github:hercules-ci/arion" // unstable "nixpkgs";
    bitwarden-menu = flake "github:firecat53/bitwarden-menu" // unstable "nixpkgs";
    compose2nix = flake "github:aksiksi/compose2nix" // unstable "nixpkgs";
    conduwuit = flake "github:Myned/conduwuit" // unstable "nixpkgs";
    disko = flake "github:nix-community/disko" // unstable "nixpkgs";
    fw-fanctrl = flake "github:TamtamHero/fw-fanctrl/packaging/nix" // unstable "nixpkgs";
    home-manager-unstable = flake "github:nix-community/home-manager" // unstable "nixpkgs";
    hypridle = flake "github:hyprwm/hypridle" // unstable "nixpkgs";
    hyprland = flake "github:hyprwm/Hyprland?ref=v0.45.2" // unstable "nixpkgs";
    hyprland-contrib = flake "github:hyprwm/contrib" // unstable "nixpkgs";
    hyprland-plugins = flake "github:hyprwm/hyprland-plugins" // unstable "nixpkgs" // follows "hyprland";
    hyprlock = flake "github:hyprwm/hyprlock" // unstable "nixpkgs";
    hyprpaper = flake "github:hyprwm/hyprpaper" // unstable "nixpkgs";
    hyprpicker = flake "github:hyprwm/hyprpicker" // unstable "nixpkgs";
    jovian-nixos = flake "github:Jovian-Experiments/Jovian-NixOS" // unstable "nixpkgs";
    niri = flake "github:YaLTeR/niri" // unstable "nixpkgs";
    niri-flake = flake "github:sodiboo/niri-flake" // unstable "nixpkgs";
    nix-alien = flake "github:thiagokokada/nix-alien" // unstable "nixpkgs";
    nix-flatpak = flake "github:gmodena/nix-flatpak?ref=v0.5.1";
    nix-index-database-unstable = flake "github:nix-community/nix-index-database" // unstable "nixpkgs";
    nix-vscode-extensions = flake "github:nix-community/nix-vscode-extensions" // unstable "nixpkgs";
    nixd = flake "github:nix-community/nixd" // unstable "nixpkgs";
    nixgl-unstable = flake "github:nix-community/nixGL" // unstable "nixpkgs";
    nur-unstable = flake "github:nix-community/NUR" // unstable "nixpkgs";
    stylix-unstable = flake "github:danth/stylix" // unstable "nixpkgs";
    walker = flake "github:abenz1267/walker?ref=v0.12.8" // unstable "nixpkgs";
    zen-browser = flake "github:youwen5/zen-browser-flake" // unstable "nixpkgs";

    ### Branches
    nixpkgs-master = flake "github:NixOS/nixpkgs/master";

    ### Source code
    cisco-packettracer8 = source "file:///home/myned/SYNC/linux/config/cisco/CiscoPacketTracer822_amd64_signed.deb";
    firefox-gnome-theme = source "github:rafaelmardojai/firefox-gnome-theme";
    lifx-cli = source "github:Rawa/lifx-cli";
    steamtinkerlaunch = source "github:sonic2kk/steamtinkerlaunch";
    thunderbird-gnome-theme = source "github:rafaelmardojai/thunderbird-gnome-theme";
    virtio-win = source "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.262-2/virtio-win.iso";
  };

  outputs = inputs: {
    # TODO: Use forAllSystems
    # FIXME: nixd always uses nixfmt when importing flakes
    # https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-fmt
    # https://github.com/kamadorueda/alejandra/blob/main/STYLE.md
    formatter.x86_64-linux = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.alejandra;

    nixosConfigurations = let
      # TODO: Use inline modules instead of specialArgs
      # https://jade.fyi/blog/flakes-arent-real#nixos-modules
      # Boilerplate systems with global imports
      #!! There is no default nixpkgs, inputs.<nixpkgs|home-manager>-BRANCH must exist
      #?? branch = common "BRANCH" "ARCHITECTURE" [ MODULES ]
      common = branch: arch: modules:
        with inputs."nixpkgs-${branch}".lib;
          nixosSystem {
            system = arch;

            specialArgs = {
              inherit inputs;

              # Pass home-manager lib through nixpkgs lib
              #?? lib.home-manager.*
              lib = recursiveUpdate inputs."nixpkgs-${branch}".lib {home-manager = inputs."home-manager-${branch}".lib;};
            };

            # TODO: Clean up optional attributes with each new release
            #!! Options will diverge between branches over time
            #?? with lib; optionalAttrs (versionAtLeast version "VERSION") { ... };
            modules =
              modules
              ++ [
                ./options
                ./configuration.nix

                #!! Avoid globally importing modules that are not guarded by .enable
                # https://github.com/NixOS/nixpkgs/issues/137168
                (
                  {inputs, ...}: {
                    imports =
                      [
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
                      ]
                      ++ optionals (versionAtLeast version "25.05") [
                        inputs.jovian-nixos.nixosModules.default
                      ];

                    # TODO: Use home-manager.sharedModules for all options
                    home-manager.sharedModules = [
                      inputs."nix-index-database-${branch}".hmModules.nix-index
                      inputs.ags.homeManagerModules.default
                      inputs.anyrun.homeManagerModules.default
                      inputs.nix-flatpak.homeManagerModules.nix-flatpak
                      inputs.walker.homeManagerModules.default

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
                )
              ];
          };

      #?? system = branch "ARCHITECTURE" [ MODULES ]
      stable = arch: modules: common "stable" "${arch}-linux" modules;
      unstable = arch: modules: common "unstable" "${arch}-linux" modules;
    in {
      ### Stable
      myarm = stable "aarch64" [./profiles/server ./machines/myarm];
      myne = stable "x86_64" [./profiles/server ./machines/myne];
      mypi3 = stable "aarch64" [./profiles/sbc ./machines/mypi3];

      ### Unstable
      myeck = unstable "x86_64" [./profiles/console ./machines/myeck];
      mynix = unstable "x86_64" [./profiles/desktop ./machines/mynix];
      myork = unstable "x86_64" [./profiles/laptop ./machines/myork];
    };
  };
}
