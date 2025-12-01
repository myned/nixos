{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.menus.networkmanager-dmenu;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.menus.networkmanager-dmenu = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/firecat53/networkmanager-dmenu
    environment.systemPackages = [pkgs.networkmanager_dmenu];

    home-manager.sharedModules = [
      {
        # https://github.com/firecat53/networkmanager-dmenu/blob/main/config.ini.example
        xdg.configFile = {
          "networkmanager-dmenu/config.ini".text = let
            dmenu =
              if config.custom.menu == "rofi"
              then "${config.custom.menus.dmenu.show} -p 󰛳"
              else config.custom.menus.dmenu.show;
          in ''
            [dmenu]
            compact = true
            dmenu_command = ${dmenu}
            active_chars = 
            highlight = true
            wifi_icons = 󰤯󰤟󰤢󰤥󰤨
            format = {icon}    {name}

            [dmenu_passphrase]
            obscure = true
          '';
        };
      }
    ];
  };
}
