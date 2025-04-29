{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.bitwarden-menu;
  hm = config.home-manager.users.${config.custom.username};

  walker = getExe hm.programs.walker.package;
in {
  options.custom.programs.bitwarden-menu = {
    enable = mkOption {default = false;};
  };

  config = {
    # https://github.com/firecat53/bitwarden-menu
    environment.systemPackages = with pkgs; [
      bitwarden-cli
      bitwarden-menu
    ];

    home-manager.sharedModules = mkIf cfg.enable [
      {
        # TODO: Check for official options
        # https://github.com/firecat53/bitwarden-menu/blob/main/docs/configure.md
        xdg.configFile."bwm/config.ini".text = generators.toINI {} {
          dmenu = {
            dmenu_command = "${walker} --dmenu --forceprint";
          };

          dmenu_passphrase = {
            obscure = true;
          };

          vault = {
            server_1 = "https://vault.${config.custom.domain}";
            login_1 = "${config.custom.username}@${config.custom.domain}";
            twofactor_1 = 0;
          };
        };
      }
    ];
  };
}
