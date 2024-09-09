{
  config,
  inputs,
  lib,
  ...
}:

{
  age.secrets =
    let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in
    {
      "common/nix/access-tokens.conf" = secret "common/nix/access-tokens.conf";
    };

  ### NixOS
  nixpkgs =
    let
      config = {
        allowUnfree = true;

        allowInsecurePredicate =
          pkg:
          let
            name = lib.getName pkg;
          in
          # HACK: Allow all insecure electron versions
          name == "electron"

          # HACK: Some Matrix clients rely on libolm, which is deprecated
          # https://github.com/NixOS/nixpkgs/pull/334638
          || name == "cinny"
          || name == "cinny-unwrapped"
          || name == "fluffychat-linux"
          || name == "olm"
          || name == "openssl"; # Cisco Packet Tracer
      };
    in
    {
      inherit config;

      overlays = [
        (
          final: prev:
          let
            nixpkgs =
              branch:
              import inputs."nixpkgs-${branch}" {
                inherit config;
                system = prev.system;
              };

            stable = nixpkgs "stable";
            unstable = nixpkgs "unstable";
            staging-next = nixpkgs "staging-next";
            local = nixpkgs "local";
          in
          {
            # Overlay nixpkgs branches
            #?? nixpkgs.BRANCH.PACKAGE
            inherit stable unstable staging-next;

            # Hypr*
            hypridle = inputs.hypridle.packages.${prev.system}.default;
            hyprland = inputs.hyprland.packages.${prev.system}.default;
            hyprlock = inputs.hyprlock.packages.${prev.system}.default;

            # TODO: Remove when merged into unstable
            # https://github.com/NixOS/nixpkgs/pull/338836
            xdg-desktop-portal-hyprland =
              inputs.xdg-desktop-portal-hyprland.packages.${prev.system}.xdg-desktop-portal-hyprland;

            hyprlandPlugins = {
              hyprbars = inputs.hyprland-plugins.packages.${prev.system}.hyprbars;
            };

            # Development
            ciscoPacketTracer8 = local.ciscoPacketTracer8;
          }
        )
      ];
    };

  nix = {
    #!! Override upstream nix
    # TODO: Try lix v2.92.0
    # https://git.lix.systems/lix-project/lix
    #// package = pkgs.lix;

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
      warn-dirty = false; # Git tree is usually dirty
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Binary caches
      trusted-users = [
        "root"
        "@wheel"
      ];

      trusted-substituters = [
        "https://anyrun.cachix.org"
        "https://attic.kennel.juneis.dog/conduwuit"
        "https://ezkea.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "conduwuit:BbycGUgTISsltcmH0qNjFR9dbrQNYgdIAcmViSGoVTE="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    #!! Handled by programs.nh.clean
    # Garbage collection
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 7d"; # Delete old generations
    # };

    # API access tokens to increase rate limits
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

    extraSpecialArgs = {
      inherit inputs;
    };

    users.${config.custom.username} = {
      programs.home-manager.enable = true;
      systemd.user.startServices = "sd-switch"; # Start/stop user services immediately

      # Inherit configuration.nix
      nixpkgs.config = config.nixpkgs.config;

      nix.gc = {
        automatic = config.nix.gc.automatic;
        frequency = config.nix.gc.dates;
        options = config.nix.gc.options;
      };

      home = {
        username = config.custom.username;
        homeDirectory = "/home/${config.custom.username}";

        #!! DO NOT MODIFY ###
        stateVersion = "23.11";
        #!! ############# ###
      };
    };
  };
}
