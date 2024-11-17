{
  config,
  lib,
  ...
}:
with lib; let
  wofi = "${config.home-manager.users.${config.custom.username}.programs.wofi.package}/bin/wofi";

  cfg = config.custom.programs.bitwarden-menu;
in {
  options.custom.programs.bitwarden-menu.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/firecat53/bitwarden-menu
    #!! Options not available, files written directly
    # https://github.com/firecat53/bitwarden-menu/blob/main/docs/configure.md
    xdg.configFile."bwm/config.ini".text = ''
      [dmenu]
      dmenu_command = ${wofi} --dmenu

      [dmenu_passphrase]
      obscure = True

      # FIXME: Login options taking effect
      [vault]
      server = https://vault.bitwarden.com
      twofactor = 0
      session_timeout_min = 720
    '';
  };
}
