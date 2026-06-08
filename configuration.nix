{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
  ];

  ### NixOS
  nixpkgs = let
    config = {
      allowUnfree = true;

      # HACK: Allow insecure packages
      allowInsecurePredicate = pkg: let
        name = getName pkg;
      in
        name == "ventoy-gtk3";
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

          master = nixpkgs "master";
          myned = nixpkgs "myned";
          unstable = nixpkgs "unstable";
        in {
          # Overlay nixpkgs branches
          #?? nixpkgs.<branch>.<package>
          inherit master myned unstable;

          ### Packages
          # https://github.com/NixOS/nixpkgs/issues/384555
          bottles = prev.bottles.override {removeWarningPopup = true;};

          # TODO: Remove when shm is supported upstream
          # https://github.com/niri-wm/niri/pull/1791
          niri = prev.niri.overrideAttrs {
            patches = [
              (pkgs.fetchpatch {
                url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_4~19..tag_support-shm-sharing_4.patch"; # https://github.com/niri-wm/niri/pull/1791#issuecomment-4347668397
                sha256 = "sha256-mfX0CVJWSFb/Hr1lDvlggphpXc2PI6C5CBa+aGwkVIM=";
              })
            ];
          };
        }
      )
    ];
  };

  nix = {
    #// package = pkgs.nixVersions.latest;
    package = pkgs.lix; # https://git.lix.systems/lix-project/lix

    #// optimise.automatic = true; # Run storage optimizer periodically

    # https://nix.dev/manual/nix/latest/command-ref/conf-file.html
    # https://nix.dev/manual/nix/2.18/command-ref/conf-file.html for Lix
    settings = {
      auto-optimise-store = true; # Run optimizer during build
      fallback = false; # Build from source if cache timeout reached
      log-lines = 1000; # Build failure log length
      min-free = 1024 * 1024 * 1024; # Trigger garbage collection at 1 GB space remaining
      trusted-users = ["@wheel"]; # Binary cache users
      warn-dirty = false; # Git tree is usually dirty

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-substituters = [
        #// "https://niri-nix.cachix.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        #// "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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

  # https://nix-community.github.io/home-manager/index.xhtml#sec-install-nixos-module
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    sharedModules = [
      {
        programs.home-manager.enable = true;
        systemd.user.startServices = true;
        home.stateVersion = config.system.stateVersion;
        nix.gc = config.nix.gc;
      }
    ];
  };

  custom.files.agenix.secrets."common/nix/access-tokens.conf" = {
    owner = config.custom.username;
    group = config.users.users.${config.custom.username}.group;
  };
}
