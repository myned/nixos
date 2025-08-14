{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.desktops.niri = {
    enable = mkOption {default = false;};
    polkit = mkOption {default = false;};
    xwayland = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    custom = {
      desktops = {
        tiling = true;

        niri = mkIf config.custom.full {
          binds.enable = true;
          input.enable = true;
          layout.enable = true;
          misc.enable = true;
          output.enable = true;
          rules.enable = true;
        };
      };

      programs = {
        # Enable custom polkit agent
        polkit.agent = !cfg.polkit;
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
      package = pkgs.niri;
      #// package = inputs.niri.packages.${pkgs.system}.default;
    };

    # BUG: Dependent on automatic home-manager module import via stylix.homeManagerIntegration.autoImport
    # https://github.com/sodiboo/niri-flake/issues/135
    #?? Attribute config.stylix.enable missing, used in niri-flake
    nixpkgs.overlays = [inputs.niri-flake.overlays.niri];

    # Disable bundled KDE polkit agent by default
    # https://github.com/sodiboo/niri-flake?tab=readme-ov-file#additional-notes
    systemd.user.services.niri-flake-polkit.enable = cfg.polkit;

    home-manager.users.${config.custom.username} = {
      programs.niri = {
        package = config.programs.niri.package;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Debug-Options
        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsdebug
        # settings = {
        #   debug =
        #     {
        #       #// disable-cursor-plane = []; # Software cursor
        #       #// disable-direct-scanout = [];
        #       #// enable-overlay-planes = [];

        #       # TODO: Enable next release > v25.05.1
        #       #// deactivate-unfocused-windows = [];
        #       #// honor-xdg-activation-with-invalid-serial = [];
        #     }
        #     // optionalAttrs config.custom.vrr {
        #       #// skip-cursor-only-updates-during-vrr = [];
        #     };
        # };
      };

      # https://github.com/sodiboo/niri-flake/blob/main/docs.md#homemodulesstylix
      stylix.targets.niri.enable = true;

      # HACK: Replace read-only finalConfig until extraConfig is supported
      # https://github.com/sodiboo/niri-flake/issues/825
      xdg.configFile = {
        # https://github.com/sodiboo/niri-flake/blob/59ed19d431324af3fcebbf623c081eae2e67ab97/flake.nix#L395
        niri-config.enable = mkForce false;

        # TODO: Move to niri-flake when supported
        # HACK: Merge kdl nodes into module config
        # https://github.com/sodiboo/niri-flake/blob/main/settings.nix
        # https://github.com/sodiboo/niri-flake/blob/main/default-config.kdl.nix
        #?? :p config.home-manager.users.<user>.xdg.configFile."niri/config.kdl".text
        #?? :p lib.findFirst (node: lib.isAttrs node && node.name == "<node>") [] config.home-manager.users.<user>.programs.niri.config
        "niri/config.kdl".text = with inputs.niri-flake.lib.kdl;
          serialize.nodes ((forEach hm.programs.niri.config (node: let
              isNode = name: isAttrs node && node.name == name;
              nodeWithChildren = children: node // {children = node.children ++ children;};
            in
              # Inject into existing nodes
              if isNode "binds"
              then
                nodeWithChildren [
                ]
              else node))
            ++ [
              # Top-level nodes
              (plain "overview" [(leaf "zoom" 0.5)])
            ]);
      };
    };
  };
}
