# Do not modify! This file is generated.

{
  inputs = {
    aagl-gtk-on-nix-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:ezKEa/aagl-gtk-on-nix/release-24.11";
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
    cisco-packettracer8 = {
      flake = false;
      url = "file:///home/myned/SYNC/linux/config/cisco/CiscoPacketTracer822_amd64_signed.deb";
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
      url = "github:nix-community/home-manager/release-24.11";
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
      url = "github:hyprwm/Hyprland?ref=v0.45.2";
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
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:nix-community/NUR";
    };
    nur-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:nix-community/NUR";
    };
    steamtinkerlaunch = {
      flake = false;
      url = "github:sonic2kk/steamtinkerlaunch";
    };
    stylix-stable = {
      inputs.nixpkgs.follows = "nixpkgs-stable";
      url = "github:danth/stylix/release-24.11";
    };
    stylix-unstable = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:danth/stylix";
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
      url = "github:abenz1267/walker?ref=v0.12.8";
    };
    zen-browser = {
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      url = "github:youwen5/zen-browser-flake";
    };
  };
  outputs = inputs: inputs.flakegen ./flake.in.nix inputs;
}