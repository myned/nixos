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

      services = {
        # Enable rootless Xwayland
        xwayland-satellite.enable = cfg.xwayland;
      };
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

          # https://github.com/YaLTeR/niri/wiki/Configuration:-Debug-Options
          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsdebug
          settings.debug = {
            #// disable-cursor-plane = []; # Software cursor
            #// disable-direct-scanout = [];
          };
        };

        # HACK: Replace read-only finalConfig until extraConfig is supported
        # https://github.com/sodiboo/niri-flake/issues/825
        xdg.configFile = {
          # https://github.com/sodiboo/niri-flake/blob/59ed19d431324af3fcebbf623c081eae2e67ab97/flake.nix#L395
          niri-config.enable = mkForce false;

          # TODO: Move to niri-flake when supported
          # HACK: Merge kdl nodes into module config
          # https://github.com/sodiboo/niri-flake/blob/main/settings.nix
          # https://github.com/sodiboo/niri-flake/blob/main/default-config.kdl.nix
          "niri/config.kdl".text = with inputs.niri-flake.lib;
            kdl.serialize.nodes (forEach hm.programs.niri.config (node:
              if isAttrs node && node.name == "layout"
              then
                recursiveUpdate node {
                  children = with kdl;
                    node.children
                    ++ [
                      # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout#shadow
                      # (plain "shadow" [
                      #   (flag "on")
                      #   (leaf "inactive-color" "#00000000")
                      # ])

                      # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout#tab-indicator
                      (plain "tab-indicator" [
                        (flag "place-within-column")
                        (leaf "active-color" "#d33682")
                        (leaf "inactive-color" "#d3368240")
                        (leaf "corner-radius" config.custom.rounding)
                        (leaf "gap" 2)
                        (leaf "gaps-between-tabs" 2)
                        (leaf "length" {total-proportion = 0.98;})
                        (leaf "width" (config.custom.border + 3))
                      ])
                    ];
                }
              else node));
        };
      }
    ];
  };
}
