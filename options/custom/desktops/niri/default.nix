{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri;

  # TODO: Use let bindings for hm config everywhere
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.desktops.niri = {
    enable = mkOption {default = false;};
    polkit = mkOption {default = false;};
    xwayland = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    custom.desktops = mkIf config.custom.full {
      niri = {
        binds.enable = true;
        input.enable = true;
        layout.enable = true;
        misc.enable = true;
        output.enable = true;
        rules.enable = true;
      };

      gnome = {
        enable = true;
        minimal = true;
      };
    };

    # https://github.com/YaLTeR/niri
    # https://github.com/sodiboo/niri-flake
    # https://github.com/sodiboo/niri-flake/blob/main/docs.md
    programs.niri = {
      enable = true;
      #// package = pkgs.niri; # nixpkgs
      package = inputs.niri.packages.${pkgs.system}.default;
    };

    nixpkgs.overlays = [inputs.niri-flake.overlays.niri];

    #!! Disabled bundled KDE polkit agent
    # https://github.com/sodiboo/niri-flake?tab=readme-ov-file#additional-notes
    systemd.user.services.niri-flake-polkit.enable = cfg.polkit;

    # Enable rootless Xwayland
    custom.services.xwayland-satellite.enable = cfg.xwayland;

    home-manager.users.${config.custom.username} = {
      programs.niri = {
        package = config.programs.niri.package;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Overview
        # HACK: Prepend validated kdl config not currently implemented in settings module for e.g. custom build
        # https://github.com/sodiboo/niri-flake/blob/main/settings.nix
        config = with inputs.niri-flake.lib;
          (internal.settings-module {config = hm;}).options.programs.niri.config.default
          # https://github.com/sodiboo/niri-flake/blob/main/default-config.kdl.nix
          ++ (with kdl; [
            # TODO: Migrate to niri.settings when released
            # https://github.com/YaLTeR/niri/pull/871
            (plain "window-rule" [
              (leaf "match" {title = "^Picture.in.[Pp]icture$";})
              (leaf "open-floating" true)
            ])
          ]);
      };
    };
  };
}
