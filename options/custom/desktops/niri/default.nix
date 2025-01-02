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
    custom = {
      desktops = mkIf config.custom.full {
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

      # Enable rootless Xwayland
      services.xwayland-satellite.enable = cfg.xwayland;
    };

    # https://github.com/YaLTeR/niri
    # https://github.com/sodiboo/niri-flake
    programs.niri = {
      enable = true;
      #// package = pkgs.niri; # nixpkgs
      package = inputs.niri.packages.${pkgs.system}.default;
    };

    nixpkgs.overlays = [inputs.niri-flake.overlays.niri];

    # Disable bundled KDE polkit agent by default
    # https://github.com/sodiboo/niri-flake?tab=readme-ov-file#additional-notes
    systemd.user.services.niri-flake-polkit.enable = cfg.polkit;

    home-manager.sharedModules = [
      {
        programs.niri = {
          package = config.programs.niri.package;

          # https://github.com/YaLTeR/niri/wiki/Configuration:-Overview
          # HACK: Prepend validated kdl config not currently implemented in settings module for e.g. custom build
          # https://github.com/sodiboo/niri-flake/blob/main/settings.nix
          config = let
            # BUG: Fixed width may not take borders into account
            # https://github.com/YaLTeR/niri/issues/269
            pip = with config.custom; rec {
              x = gap;
              y = gap;
              w = builtins.floor (width * 0.3 - gap); # 30%
              h = builtins.floor (w * 9 / 16); # 16:9
            };
          in
            with inputs.niri-flake.lib;
              (internal.settings-module {config = hm;}).options.programs.niri.config.default
              # https://github.com/sodiboo/niri-flake/blob/main/default-config.kdl.nix
              ++ (with kdl; [
                # TODO: Migrate to window-rules when released
                # https://github.com/YaLTeR/niri/pull/871
                (plain "window-rule" [
                  (leaf "match" {is-floating = true;})
                  (plain "border" [(flag "off")])
                  (plain "focus-ring" [(flag "off")])
                ])

                (plain "window-rule" [
                  (leaf "match" {title = "^Picture.in.[Pp]icture$";})

                  (leaf "default-floating-position" {
                    x = pip.x;
                    y = pip.y;
                    relative-to = "top-right";
                  })

                  (plain "default-column-width" [(leaf "fixed" (pip.w))])
                  (plain "default-window-height" [(leaf "fixed" (pip.h))])
                  (leaf "open-floating" true)
                  (leaf "open-focused" false)
                ])
              ]);

          # https://github.com/YaLTeR/niri/wiki/Configuration:-Debug-Options
          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsdebug
          settings.debug = {
            #// disable-direct-scanout = [];

            # BUG: Crash when multiple outputs from the same monitor are enabled
            # https://github.com/YaLTeR/niri/issues/734
            disable-monitor-names = [];
          };
        };
      }
    ];
  };
}
