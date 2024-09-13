{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.fwupd;
in {
  options.custom.services.fwupd.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Fwupd
    # https://github.com/fwupd/fwupd
    services.fwupd = {
      enable = true;
      extraRemotes = ["lvfs-testing"];
    };
  };
}
