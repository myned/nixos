{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom = {
    default = mkOption {default = true;};
    minimal = mkOption {default = cfg.full;}; # TODO: Use "interactive" instead
    full = mkOption {default = false;};
    server = mkOption {default = false;};
    profile = mkOption {};
    domain = mkOption {default = "bjork.tech";};
    hostname = mkOption {};
    realname = mkOption {default = "Myned";};
    username = mkOption {default = "myned";};
    syncDir = mkOption {default = "${hm.home.homeDirectory}/SYNC";};
    border = mkOption {default = 2.0;};
    gap = mkOption {default = 5.0;};
    padding = mkOption {default = 51.0;}; # ?? journalctl --user -u waybar.service | grep height:
    rounding = mkOption {default = 16.0;};
    vm = mkOption {default = false;};
    desktop = mkOption {default = null;};
    lockscreen = mkOption {default = "hyprlock";};
    menu = mkOption {default = "walker";};

    terminal = {
      command = mkOption {
        default = getExe hm.programs.ghostty.package;
        description = "Path to the executable that launches the default terminal";
        example = getExe pkgs.kitty;
        type = types.path;
      };

      desktop = mkOption {
        default = "com.mitchellh.ghostty.desktop";
        description = "Name of the desktop file for the default terminal";
        example = "kitty.desktop";
        type = types.str;
      };
    };

    time = mkOption {
      default = "24h";
      type = types.enum ["12h" "24h"];
    };
  };

  config.custom = mkMerge [
    (mkIf cfg.default {
      arion.enable = true;
      containers.enable = true;
      files.enable = true;
      programs.enable = true;
      scripts.enable = true;
      services.enable = true;
      settings.enable = true;
    })

    (mkIf cfg.minimal {
      })

    (mkIf cfg.full {
      browsers.enable = true;
      desktops.enable = true;
      displays.enable = true;
      games.enable = true;
      #// lockscreens.enable = true;
      #// menus.enable = true;
      search.enable = true;
      vms.enable = true;
    })
  ];
}
