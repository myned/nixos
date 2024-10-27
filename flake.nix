# Do not modify! This file is generated.

{
  inputs = {
    aagl-gtk-on-nix-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:ezKEa/aagl-gtk-on-nix/release-24.05";
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
    anyrun = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:Kirottu/anyrun";
    };
    arion = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hercules-ci/arion";
    };
    bitwarden-menu = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:firecat53/bitwarden-menu";
    };
    compose2nix = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:aksiksi/compose2nix";
    };
    conduwuit = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:Myned/conduwuit";
    };
    disko = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/disko";
    };
    firefox-gnome-theme = {
      flake = false;
      url = "github:rafaelmardojai/firefox-gnome-theme/v128";
    };
    flakegen.url = "github:jorsn/flakegen";
    fw-fanctrl = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:TamtamHero/fw-fanctrl/packaging/nix";
    };
    home-manager-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:nix-community/home-manager/release-24.05";
    };
    home-manager-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/home-manager";
    };
    hypridle = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/hypridle";
    };
    hyprland = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "git+https://github.com/hyprwm/Hyprland?ref=main&rev=6e0aadc585c6d9fdaaebfa5853adbf9610897c82&submodules=1";
    };
    hyprland-contrib = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/contrib";
    };
    hyprland-plugins = {
      inputs.hyprland.follows = "hyprland";
      url = "github:hyprwm/hyprland-plugins";
    };
    hyprlock = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/hyprlock";
    };
    hyprpaper = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:hyprwm/hyprpaper";
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
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=v0.4.1";
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
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-staging-next.url = "github:NixOS/nixpkgs/staging-next";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    steamtinkerlaunch = {
      flake = false;
      url = "github:sonic2kk/steamtinkerlaunch";
    };
    thunderbird-gnome-theme = {
      flake = false;
      url = "github:rafaelmardojai/thunderbird-gnome-theme";
    };
    virtio-win = {
      flake = false;
      url = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.262-2/virtio-win.iso";
    };
    walker = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:abenz1267/walker";
    };
  };
  outputs = inputs: inputs.flakegen ./flake.in.nix inputs;
}