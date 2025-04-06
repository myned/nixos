{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.wallpaper;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.services.wallpaper = {
    enable = mkEnableOption "wallpaper";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        systemd.user.services.wallpaper = {
          Unit = {
            Description = "Periodically change wallpaper";
          };

          Install = {
            WantedBy = ["default.target"];
          };

          Service = {
            Type = "simple";
            ExecStart = hm.home.file.".local/bin/wallpaper".source;
          };
        };
      }
    ];
  };
}
