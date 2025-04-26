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
    sync = mkOption {default = "/home/myned/SYNC";};

    ### Hardware
    width = mkOption {default = 1920.0;};
    height = mkOption {default = 1080.0;};
    refresh = mkOption {default = 60.0;};
    vrr = mkOption {default = false;};
    ultrawide = mkOption {default = cfg.width * 9 / 16 > cfg.height;}; # Wider than 16:9
    hidpi = mkOption {default = cfg.scale > 1;};
    scale = mkOption {default = 1.0;};
    border = mkOption {default = 3.0;};
    gap = mkOption {default = 10.0;};
    padding = mkOption {default = 51.0;}; # ?? journalctl --user -u waybar.service | grep height:
    rounding = mkOption {default = 16.0;};

    ### Misc
    desktop = mkOption {default = null;};

    lockscreen = mkOption {default = "hyprlock";};
    menu = mkOption {default = "rofi";};

    browser = {
      # TODO: Use lib.getExe' instead of /bin/ where possible
      command = mkOption {default = getExe hm.programs.librewolf.finalPackage;};
      desktop = mkOption {default = "librewolf.desktop";};
    };
  };
}
