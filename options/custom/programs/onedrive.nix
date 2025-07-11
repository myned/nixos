{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.onedrive;
in {
  options.custom.programs.onedrive.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/abraunegg/onedrive
    #!! Login is imperative
    #?? onedrive
    #?? systemctl --user enable --now onedrive@onedrive.service

    #!! Option not available, files written directly
    xdg.configFile = {
      # https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#configuration
      "onedrive/config".text = ''
        sync_dir = "~/SYNC/edu/hawkeye"
      '';

      # https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#performing-a-selective-sync-via-sync_list-file
      "onedrive/sync_list".text = ''
        !/Apps/
        !/Attachments/
        /*
      '';
    };
  };
}
