{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.networkmanager-dmenu;
in {
  options.custom.programs.networkmanager-dmenu.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/firecat53/networkmanager-dmenu
    # https://github.com/firecat53/networkmanager-dmenu/blob/main/config.ini.example
    #!! Option not available, files written directly
    # FIXME: active_chars does not take effect
    home.file.".config/networkmanager-dmenu/config.ini".text = let
      wofi = "${config.home-manager.users.${config.custom.username}.programs.wofi.package}/bin/wofi";
    in ''
      [dmenu]
      dmenu_command = ${wofi} --dmenu --lines 11
      active_chars = >
      wifi_icons = 󰤯󰤟󰤢󰤥󰤨
      format = {icon}  {name}
    '';
  };
}
