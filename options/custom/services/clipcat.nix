{
  config,
  lib,
  ...
}:
with lib; let
  wofi = "${config.home-manager.users.${config.custom.username}.programs.wofi.package}/bin/wofi";

  cfg = config.custom.services.clipcat;
in {
  options.custom.services.clipcat.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # BUG: Random high CPU usage
    # https://github.com/xrelkd/clipcat/issues/347
    # https://github.com/xrelkd/clipcat
    services.clipcat.enable = true;

    # https://github.com/xrelkd/clipcat?tab=readme-ov-file#configuration
    home-manager.users.${config.custom.username}.xdg.configFile = {
      "clipcat/clipcatd.toml".text = ''
        daemonize = false
        max_history = 100

        [watcher]
        enable_clipboard = true
        enable_primary = false

        [grpc]
        enable_http = false
      '';

      "clipcat/clipcat-menu.toml".text = ''
        finder = "custom_finder"

        [custom_finder]
        program = "${wofi}"
        args = ["--dmenu"]
      '';
    };
  };
}
