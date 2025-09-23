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
    sync = mkOption {default = "${hm.home.homeDirectory}/SYNC";};

    ### Hardware
    width = mkOption {default = 1920.0;};
    height = mkOption {default = 1080.0;};
    refresh = mkOption {default = 60.0;};
    vrr = mkOption {default = false;};
    ultrawide = mkOption {default = cfg.width * 9 / 16 > cfg.height;}; # Wider than 16:9
    hdr = mkOption {default = false;};
    hidpi = mkOption {default = cfg.scale > 1;};
    scale = mkOption {default = 1.0;};
    border = mkOption {default = 3.0;};
    gap = mkOption {default = 15.0;};
    padding = mkOption {default = 51.0;}; # ?? journalctl --user -u waybar.service | grep height:
    rounding = mkOption {default = 16.0;};
    vm = mkOption {default = false;};

    ### Misc
    desktop = mkOption {default = null;};
    lockscreen = mkOption {default = "swaylock";};
    menu = mkOption {default = "rofi";};

    browser = {
      command = mkOption {
        # HACK: Get hm finalPackage from package list
        default = getExe (lib.findFirst (p:
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
}
