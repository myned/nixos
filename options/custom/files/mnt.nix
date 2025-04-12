{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.files.mnt;
in {
  options.custom.files.mnt.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # Set /mnt permissions
    systemd.tmpfiles.settings.mnt = {
      "/mnt" = {
        z = {
          mode = "0755";
          user = "root";
          group = "root";
        };
      };
    };
  };
}
