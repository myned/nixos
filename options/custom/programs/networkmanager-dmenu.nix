{
  config,
  lib,
  ...
}:
with lib; let
  menu = config.home-manager.users.${config.custom.username}.home.file.".local/bin/menu".source;

  cfg = config.custom.programs.networkmanager-dmenu;
in {
  options.custom.programs.networkmanager-dmenu.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/firecat53/networkmanager-dmenu
    # https://github.com/firecat53/networkmanager-dmenu/blob/main/config.ini.example
    #!! Option not available, files written directly
    # FIXME: active_chars does not take effect
    xdg.configFile."networkmanager-dmenu/config.ini".text = ''
      [dmenu]
      dmenu_command = ${menu} --input
      active_chars = >
      wifi_icons = 󰤯󰤟󰤢󰤥󰤨
      format = {icon}  {name}
    '';
  };
}
