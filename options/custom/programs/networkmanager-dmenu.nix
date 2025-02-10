{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.networkmanager-dmenu;

  bash = getExe pkgs.bash;
in {
  options.custom.programs.networkmanager-dmenu.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/firecat53/networkmanager-dmenu
    environment.systemPackages = [pkgs.networkmanager_dmenu];

    home-manager.users.${config.custom.username} = {
      # https://github.com/firecat53/networkmanager-dmenu/blob/main/config.ini.example
      #!! Option not available, files written directly
      xdg.configFile."networkmanager-dmenu/config.ini".text = ''
        [dmenu]
        compact = true
        dmenu_command = ${bash} -c '${config.custom.menus.network.show}'
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
