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
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.7.0"; # https://github.com/gmodena/nix-flatpak
    nix-net-lib.url = "github:0xCCF4/nix-net-lib"; # https://github.com/0xCCF4/nix-net-lib
    nixos-hardware.url = "github:NixOS/nixos-hardware"; # https://github.com/NixOS/nixos-hardware
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05"; # https://github.com/NixOS/nixpkgs/tree/nixos-26.05
    nixpkgs-master.url = "github:NixOS/nixpkgs/master"; # https://github.com/NixOS/nixpkgs
    nixpkgs-myned.url = "github:myned/nixpkgs/master"; # https://github.com/myned/nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable"; # https://github.com/NixOS/nixpkgs/tree/nixos-unstable
    vintagestory-nix.url = "github:PierreBorine/vintagestory-nix"; # https://github.com/PierreBorine/vintagestory-nix

    ### Follows
    # https://github.com/ryantm/agenix
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/hercules-ci/arion
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/disko
    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/AvengeMedia/danksearch
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/AvengeMedia/DankMaterialShell
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/AvengeMedia/dms-plugin-registry
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Lehmanator/fprint-clear
    fprint-clear = {
      url = "github:Lehmanator/fprint-clear";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Jovian-Experiments/Jovian-NixOS
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/lanzaboote
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://codeberg.org/BANanaD3V/niri-nix
    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
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

    # https://git.bjork.tech/myned/site
    site = {
      url = "git+https://git.bjork.tech/myned/site?ref=prod";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/nix-community/stylix
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Source code
    # https://github.com/Rawa/lifx-cli
    lifx-cli = {
      url = "github:Rawa/lifx-cli";
      flake = false;
    };

    ovenmediaengine = {
      url = "github:OvenMediaLabs/OvenMediaEngine";
      flake = false;
    };

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
        #// formatter = pkgs.alejandra;
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
        # https://wiki.nixos.org/wiki/NixOS_system_configuration#Defining_NixOS_as_a_flake
        nixosConfigurations = let
          nixos = system: modules:
            inputs.nixpkgs.lib.nixosSystem {
              inherit system;
              modules = commonModules ++ modules;
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
