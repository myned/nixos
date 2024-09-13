{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.onedrive;
in {
  options.custom.services.onedrive.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/abraunegg/onedrive
    services.onedrive.enable = true;
  };
}
