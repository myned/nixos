{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # Use packages from local derivation
  git = config.home-manager.users.${config.custom.username}.programs.git.package;
  hyprland =
    config.home-manager.users.${config.custom.username}.wayland.windowManager.hyprland.finalPackage;
  walker = config.home-manager.users.${config.custom.username}.programs.walker.package;
  wofi = config.home-manager.users.${config.custom.username}.programs.wofi.package;
in {
  config.home-manager.users.${config.custom.username}.home.file = let
    # Place script.ext in the same directory as this file
    #?? pkg = (SHELL "NAME" [ DEPENDENCIES ])
    # https://nixos.org/manual/nixpkgs/unstable/#trivial-builder-writeShellApplication
    bash = name: dependencies: {
      ".local/bin/${name}".source =
        pkgs.writeShellApplication {
          inherit name;

          # https://github.com/NixOS/nixpkgs/pull/261115
          #// excludeShellChecks = ["SC2154"]; # argc evaluates variables at runtime

          runtimeInputs = dependencies;
          text = builtins.readFile ./${name}.sh;
        }
        + "/bin/${name}";
    };

    # https://wiki.nixos.org/wiki/Nix-writers#Python3
    # Always latest python version in nixpkgs, use writers.makePythonWriter to pin version
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/writers/scripts.nix#L605
    python = name: dependencies: {
      ".local/bin/${name}".source =
        pkgs.writers.writePython3Bin name {libraries = dependencies;}
        # Disable linting
        # https://flake8.pycqa.org/en/3.1.1/user/ignoring-errors.html#ignoring-entire-files
        ("# flake8: noqa\n" + builtins.readFile ./${name}.py)
        + "/bin/${name}";
    };
  in
    mkIf config.custom.full (
      with pkgs;
        mkMerge (
          [
            # Bash files with extension .sh
            (bash "audio" [
              easyeffects
              libnotify
            ])
            (bash "bwm" [
              bitwarden-cli
              coreutils
              jq
              libnotify
              wl-clipboard
              wofi
              xclip
            ])
            (bash "calc" [
              coreutils
              libnotify
              libqalculate
              wl-clipboard
              wofi
              xclip
            ])
            (bash "clipboard" [
              cliphist
              libnotify
              procps
              wl-clipboard
              wofi
              xclip
            ])
            (bash "close" [
              coreutils
              hyprland
              jq
              libnotify
            ])
            (bash "fingerprints" [
              fprintd
              libnotify
            ])
            (bash "inhibit" [
              coreutils
              libnotify
              systemd
            ])
            (bash "left" [
              hyprland
              jq
              libnotify
            ])
            (bash "menu" [
              networkmanager_dmenu
              rofi-rbw
              walker
            ])
            (bash "minimize" [
              hyprland
              jq
              libnotify
            ])
            (bash "network" [
              libnotify
              networkmanager
            ])
            (bash "nixos" [
              argc
              coreutils
              git
              nh
              nix
              nixos-rebuild
              nvd
              systemd
            ])
            (bash "power" [
              libnotify
              power-profiles-daemon
            ])
            (bash "screenshot" [
              argc
              coreutils
              grimblast
              imagemagick
              libnotify
              swappy
            ])
            (bash "toggle" [
              gnugrep
              hyprland
              jq
              libnotify
            ])
            (bash "vm" [
              coreutils
              freerdp3
              iputils
              libnotify
              libvirt
              remmina
            ])
            (bash "vpn" [
              gnused
              jq
              libnotify
              tailscale
            ])
            (bash "vrr" [
              hyprland
              jq
              libnotify
            ])
            (bash "wallpaper" [
              coreutils
              fd
              imagemagick
              libnotify
              rsync
              swww
              tailscale
            ])
          ]
          ++ (with pkgs.python3Packages; [
            # Python files with extension .py
            (python "bcrypt" [bcrypt])
          ])
        )
    );
}
