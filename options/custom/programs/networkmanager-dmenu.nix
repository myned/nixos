{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.networkmanager-dmenu;
  hm = config.home-manager.users.${config.custom.username};

  rofi = getExe hm.programs.rofi.package;
in {
  options.custom.programs.networkmanager-dmenu.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/firecat53/networkmanager-dmenu
    environment.systemPackages = [pkgs.networkmanager_dmenu];

    home-manager.users.${config.custom.username} = {
      # https://github.com/firecat53/networkmanager-dmenu/blob/main/config.ini.example
      #!! Option not available, files written directly
      xdg.configFile."networkmanager-dmenu/config.ini".text = let
        menu =
          if config.custom.menu == "rofi"
          then "${rofi} -dmenu -p 󰛳"
          else "";
      in ''
        [dmenu]
        compact = true
        dmenu_command = ${menu}
        list_saved = true
        active_chars = 
        highlight = true
        wifi_icons = 󰤯󰤟󰤢󰤥󰤨
        format = {icon}    {name}

        [dmenu_passphrase]
        obscure = true
      '';
    };
  };
}
