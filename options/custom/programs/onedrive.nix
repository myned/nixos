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
    programs.onedrive = {
      enable = true;

      # https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#configuration
      settings = {
        sync_dir = "~/OneDrive";
      };
    };

    # xdg.configFile = {
    #   # https://github.com/abraunegg/onedrive/blob/master/docs/USAGE.md#performing-a-selective-sync-via-sync_list-file
    #   "onedrive/sync_list".text = ''
    #     !/Apps/
    #     !/Attachments/
    #     /*
    #   '';
    # };
  };
}
