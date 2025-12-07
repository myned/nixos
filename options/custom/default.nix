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
    ### Profiles
    default = mkOption {default = true;};
    full = mkOption {default = false;};
    minimal = mkOption {default = cfg.full;}; # TODO: Use "interactive" instead
    profile = mkOption {};

    ### Users
    domain = mkOption {default = "bjork.tech";};
    hostname = mkOption {};
    realname = mkOption {default = "Myned";};
    username = mkOption {default = "myned";};
    syncDir = mkOption {default = "${hm.home.homeDirectory}/SYNC";};

    ### Hardware
    border = mkOption {default = 3.0;};
    gap = mkOption {default = 10.0;};
    padding = mkOption {default = 51.0;}; # ?? journalctl --user -u waybar.service | grep height:
    rounding = mkOption {default = 16.0;};
    vm = mkOption {default = false;};

    ### Misc
    desktop = mkOption {default = null;};
    lockscreen = mkOption {default = "hyprlock";};
    menu = mkOption {default = "walker";};

    browser = {
      appId = mkOption {
        default = "google-chrome";
        description = "App ID / class of the browser as seen by the window manager";
        example = "google-chrome";
        type = types.str;
      };

      command = mkOption {
        # HACK: Get hm finalPackage from package list
        default = getExe (findFirst (p:
            if hasAttr "pname" p
            then p.pname == "google-chrome"
            else false)
          null
          hm.home.packages);

        description = "Path to the executable that launches the default browser";
        example = getExe pkgs.firefox;
        type = types.path;
      };

      desktop = mkOption {
        default = "google-chrome.desktop";
        description = "Name of the desktop file for the default browser";
        example = "firefox.desktop";
        type = types.str;
      };
    };

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
      })

    (mkIf cfg.minimal {
      })

    (mkIf cfg.full {
      display.enable = true;
      search.enable = true;
    })
  ];
}
