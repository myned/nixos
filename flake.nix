# Do not modify! This file is generated.

{
  inputs = {
    aagl-gtk-on-nix-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:ezKEa/aagl-gtk-on-nix/release-25.05";
    };
    aagl-gtk-on-nix-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:ezKEa/aagl-gtk-on-nix";
    };
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:ryantm/agenix";
    };
    ags = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:Aylur/ags";
    };
    arion = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hercules-ci/arion";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/disko";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flakegen.url = "github:jorsn/flakegen";
    fw-fanctrl = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:TamtamHero/fw-fanctrl/packaging/nix";
    };
    home-manager-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:nix-community/home-manager/release-25.05";
    };
    home-manager-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/home-manager";
    };
    hypridle = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/hypridle";
    };
    hyprlock = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/hyprlock";
    };
    hyprpicker = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/hyprpicker";
    };
    jovian-nixos = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:Jovian-Experiments/Jovian-NixOS";
    };
    lifx-cli = {
      flake = false;
      url = "github:Rawa/lifx-cli";
    };
    niri = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:YaLTeR/niri";
    };
    niri-flake = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:sodiboo/niri-flake";
    };
    nix-alien = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:thiagokokada/nix-alien";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.5.1";
    nix-index-database-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:nix-community/nix-index-database";
    };
    nix-index-database-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nix-index-database";
    };
    nix-vscode-extensions = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nix-vscode-extensions";
    };
    nixd = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nixd";
    };
    nixgl-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:nix-community/nixGL";
    };
    nixgl-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/nixGL";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-gitbutler.url = "github:25huizengek1/nixpkgs/gitbutler";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-myned.url = "github:myned/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvirt = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:AshleyYakeley/NixVirt/v0.6.0";
    };
    nur-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:nix-community/NUR";
    };
    nur-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/NUR";
    };
    stylix-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:danth/stylix/release-25.05";
    };
    stylix-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:danth/stylix";
    };
    virtio-win = {
      flake = false;
      url = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win.iso";
    };
    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:youwen5/zen-browser-flake";
    };
  };
  outputs = inputs: inputs.flakegen ./flake.in.nix inputs;
}