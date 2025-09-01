{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.onedrive;
in {
  options.custom.programs.onedrive = {
    enable = mkEnableOption "onedrive";

    syncDir = mkOption {
      default = "~/OneDrive";
      description = "Path to synced directory";
      example = "/mnt/local/onedrive";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/abraunegg/onedrive
      #!! Login is imperative
      #?? onedrive
      #?? systemctl --user enable --now onedrive.service
      programs.onedrive = {
        enable = true;

        # https://github.com/abraunegg/onedrive/blob/master/docs/application-config-options.md
        settings = {
          #!! Attempt to work around Obsidian atomic state
          delay_inotify_processing = "true";
          force_session_upload = "true";

          #!! SharePoint "file enrichment" modifies uploads >:(
          # https://github.com/OneDrive/onedrive-api-docs/issues/935
          disable_upload_validation = "true";

          disable_notifications = "true"; # Initialization notification on every start :(
          skip_dotfiles = "true";
          sync_dir = cfg.syncDir;
        };
      };
    };
  };
}
