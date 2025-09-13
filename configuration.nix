{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  hm = config.home-manager.users.${config.custom.username};
in {
  age.secrets = let
    secret = filename: {
      file = "${inputs.self}/secrets/${filename}";
      owner = config.custom.username;
      group = config.users.users.${config.custom.username}.group;
    };
  in {
    "common/nix/access-tokens.conf" = secret "common/nix/access-tokens.conf";
  };

  ### NixOS
  nixpkgs = let
    config = {
      allowUnfree = true;

      allowInsecurePredicate = pkg: let
        name = getName pkg;
      in
        # HACK: Allow all insecure electron versions
        name
        == "electron"
        # HACK: Ventoy uses opaque binary blobs, causing security concerns
        # https://github.com/NixOS/nixpkgs/issues/404663
        || name == "ventoy-gtk3"
        # HACK: Some Matrix clients rely on libolm, which is deprecated
        # https://github.com/NixOS/nixpkgs/pull/334638
        || name == "cinny"
        || name == "cinny-unwrapped"
        || name == "fluffychat-linux"
        || name == "olm"
        # Cisco Packet Tracer
        || name == "openssl";
    };
  in {
    inherit config;

    overlays = [
      (
        final: prev: let
          nixpkgs = branch:
            import inputs."nixpkgs-${branch}" {
              inherit config;
              system = prev.system;
            };

          stable = nixpkgs "stable";
          unstable = nixpkgs "unstable";
          master = nixpkgs "master";
          myned = nixpkgs "myned";
          gitbutler = nixpkgs "gitbutler";
        in {
          # Overlay nixpkgs branches
          #?? nixpkgs.BRANCH.PACKAGE
          inherit stable unstable master myned;

          ### Packages
          # https://github.com/NixOS/nixpkgs/issues/384555
          bottles = prev.bottles.override {removeWarningPopup = true;};

          # TODO: Remove when in stable
          btrfs-list = unstable.btrfs-list;

          # TODO: Remove when merged into unstable
          # https://github.com/NixOS/nixpkgs/pull/424156
          gitbutler = gitbutler.gitbutler;

          # TODO: Remove when fixed
          # https://github.com/NixOS/nixpkgs/issues/389638
          # https://github.com/NixOS/nixpkgs/pull/390171
          rustdesk-flutter = stable.rustdesk-flutter;

          # HACK: Ignore tests to fix build
          # https://github.com/tailscale/tailscale/issues/16966
          tailscale = prev.tailscale.overrideAttrs (old: {
            checkFlags =
              builtins.map (
                flag:
                  if prev.lib.hasPrefix "-skip=" flag
                  then flag + "|^TestGetList$|^TestIgnoreLocallyBoundPorts$|^TestPoller$|^TestRTT$|^TestXDP$"
                  else flag
              )
              old.checkFlags;
          });

          # TODO: Use official package when available
          # https://github.com/NixOS/nixpkgs/issues/327982
          zen-browser = inputs.zen-browser.packages.${prev.system}.zen-browser;
          zen-browser-unwrapped = inputs.zen-browser.packages.${prev.system}.zen-browser-unwrapped;

          ### Python
          # https://nixos.org/manual/nixpkgs/unstable/#how-to-override-a-python-package-for-all-python-versions-using-extensions
          #?? PKG = pyprev.PKG.overridePythonAttrs {};
          # pythonPackagesExtensions =
          #   prev.pythonPackagesExtensions
          #   ++ [
          #     (pyfinal: pyprev: {
          #     })
          #   ];
        }
      )
    ];
  };

  nix = {
    #!! Override upstream nix
    # https://git.lix.systems/lix-project/lix
    package = pkgs.lix;

    # BUG: Absolute paths are forbidden in pure mode
    # https://github.com/NixOS/nix/issues/11030
    #// package = pkgs.nixVersions.latest;

    #// optimise.automatic = true; # Run storage optimizer periodically

    # https://nix.dev/manual/nix/latest/command-ref/conf-file.html
    # https://nix.dev/manual/nix/2.18/command-ref/conf-file.html for Lix
    settings = {
      auto-optimise-store = true; # Run optimizer during build
      fallback = true; # Build from source if cache timeout reached
      log-lines = 1000; # Build failure log length
      min-free = 1024 * 1024 * 1024; # Trigger garbage collection at 1 GB space remaining
      trusted-users = ["@wheel"]; # Binary caches
      warn-dirty = false; # Git tree is usually dirty

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-substituters = [
        "https://ezkea.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://walker.cachix.org"
      ];

      trusted-public-keys = [
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      ];
    };

    # Nix store garbage collection
    # Alternative: custom.programs.nh.clean
    # https://nix.dev/manual/nix/latest/command-ref/nix-collect-garbage
    gc = {
      automatic = true;
      dates = "weekly";

      # BUG: Does not support +N period
      # https://github.com/NixOS/nix/issues/9455
      # https://github.com/NixOS/nix/pull/10426
      options = "--delete-older-than 7d";
    };

    # API access tokens to increase rate limits
    #!! Requires nix to be run as root for read access to agenix secrets
    # https://nix.dev/manual/nix/latest/command-ref/conf-file#conf-access-tokens
    # https://github.com/NixOS/nix/issues/6536#issuecomment-1254858889
    # https://github.com/settings/tokens
    extraOptions = "!include ${config.age.secrets."common/nix/access-tokens.conf".path}";
  };

  system = {
    nixos.label = ""; # Partially clean up boot entries

    #!! DO NOT MODIFY ###
    stateVersion = "23.11";
    #!! ############# ###
  };

  ### Home Manager
  # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};

    # Common options for every user
    sharedModules = [
      {
        programs.home-manager.enable = true;
        systemd.user.startServices = true;
        home.stateVersion = config.system.stateVersion;

        nix.gc = with config.nix.gc;
          {
            inherit automatic options;
          }
          // (
            if (versionAtLeast version "25.11")
            then {
              inherit dates;
            }
            else {
              frequency = toString dates;
            }
          );
      }
    ];
  };
}
