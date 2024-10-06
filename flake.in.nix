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
    nixpkgs-stable = flake "github:NixOS/nixpkgs/nixos-24.05";

    # Common flakes
    home-manager-stable = flake "github:nix-community/home-manager/release-24.05" // stable "nixpkgs";
    nix-index-database-stable = flake "github:nix-community/nix-index-database" // stable "nixpkgs";

    # Desktop flakes
    aagl-gtk-on-nix-stable = flake "github:ezKEa/aagl-gtk-on-nix/release-24.05" // stable "nixpkgs";

    ### Unstable
    nixpkgs-unstable = flake "github:NixOS/nixpkgs/nixos-unstable";

    # Common flakes
    agenix = flake "github:ryantm/agenix" // unstable "nixpkgs";
    arion = flake "github:hercules-ci/arion" // unstable "nixpkgs";
    compose2nix = flake "github:aksiksi/compose2nix" // unstable "nixpkgs";
    disko = flake "github:nix-community/disko" // unstable "nixpkgs";
    home-manager-unstable = flake "github:nix-community/home-manager" // unstable "nixpkgs";
    nix-index-database-unstable = flake "github:nix-community/nix-index-database" // unstable "nixpkgs";

    # Console flakes
    jovian-nixos = flake "github:Jovian-Experiments/Jovian-NixOS" // unstable "nixpkgs";

    # Desktop flakes
    aagl-gtk-on-nix-unstable = flake "github:ezKEa/aagl-gtk-on-nix" // unstable "nixpkgs";
    ags = flake "github:Aylur/ags" // unstable "nixpkgs";
    anyrun = flake "github:Kirottu/anyrun" // unstable "nixpkgs";
    bitwarden-menu = flake "github:firecat53/bitwarden-menu" // unstable "nixpkgs";
    fw-fanctrl = flake "github:TamtamHero/fw-fanctrl/packaging/nix" // unstable "nixpkgs";
    hypridle = flake "github:hyprwm/hypridle" // unstable "nixpkgs";
    hyprland = flake "git+https://github.com/hyprwm/Hyprland?ref=refs/tags/v0.44.0&submodules=1" // unstable "nixpkgs";
    #// hyprland = flake "git+https://github.com/hyprwm/Hyprland?submodules=1" // unstable "nixpkgs";
    #// hyprland = flake "git+https://github.com/UjinT34/Hyprland?ref=vrr-cursor-fix&submodules=1" // unstable "nixpkgs";
    hyprland-contrib = flake "github:hyprwm/contrib" // unstable "nixpkgs";
    hyprland-plugins = flake "github:hyprwm/hyprland-plugins" // unstable "nixpkgs" // follows "hyprland";
    hyprlock = flake "github:hyprwm/hyprlock" // unstable "nixpkgs";
    hyprpaper = flake "github:hyprwm/hyprpaper" // unstable "nixpkgs";
    hyprpicker = flake "github:hyprwm/hyprpicker" // unstable "nixpkgs";
    nix-flatpak = flake "github:gmodena/nix-flatpak?ref=v0.4.1";
    nix-vscode-extensions = flake "github:nix-community/nix-vscode-extensions" // unstable "nixpkgs";
    nixd = flake "github:nix-community/nixd" // unstable "nixpkgs";
    walker = flake "github:abenz1267/walker" // unstable "nixpkgs";

    # Server flakes
    conduwuit = flake "github:Myned/conduwuit" // unstable "nixpkgs";

    ### Staging
    nixpkgs-staging-next = flake "github:NixOS/nixpkgs/staging-next";

    ### Development
    #// nixpkgs-local = flake "git+file:///home/myned/SYNC/dev/repo/nixpkgs";
    #// hyprland = flake "git+file:///home/myned/SYNC/dev/repo/Hyprland?submodules=1";

    ### Source code
    firefox-gnome-theme = source "github:rafaelmardojai/firefox-gnome-theme/v128";
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
        inputs."nixpkgs-${branch}".lib.nixosSystem {
          system = arch;
          specialArgs = {inherit inputs;};

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
                {
                  config,
                  inputs,
                  ...
                }: {
                  imports = [
                    inputs."aagl-gtk-on-nix-${branch}".nixosModules.default
                    inputs."home-manager-${branch}".nixosModules.home-manager
                    inputs."nix-index-database-${branch}".nixosModules.nix-index
                    inputs.agenix.nixosModules.default
                    inputs.arion.nixosModules.arion
                    inputs.disko.nixosModules.disko
                    inputs.fw-fanctrl.nixosModules.default
                  ];

                  home-manager.users.${config.custom.username}.imports = [
                    inputs."nix-index-database-${branch}".hmModules.nix-index
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
