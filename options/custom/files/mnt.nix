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
    systemd.tmpfiles.rules = ["z /mnt 0755 root root"];
  };
}
