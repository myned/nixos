{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.menus;
in {
  options.custom.menus = {
    enable = mkOption {default = config.custom.full;};
    show = mkOption {default = "";};
    calculator.show = mkOption {default = "";};

    clipboard = {
      clear = mkOption {default = "";};
      show = mkOption {default = "";};
    };

    dmenu.show = mkOption {default = "";};
    emoji.show = mkOption {default = "";};
    network.show = mkOption {default = "";};
    search.show = mkOption {default = "";};
    vault.show = mkOption {default = "";};
  };

  config = mkIf cfg.enable {
    custom.menus = {
      anyrun.enable = config.custom.menu == "anyrun";
      fuzzel.enable = config.custom.menu == "fuzzel";
      rofi.enable = config.custom.menu == "rofi";
      walker.enable = config.custom.menu == "walker";
      wofi.enable = config.custom.menu == "wofi";
    };
  };
}
