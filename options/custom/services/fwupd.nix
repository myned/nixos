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
    # BUG: Cache not refreshing properly with libxmlb < 0.3.21
    # https://github.com/fwupd/fwupd/issues/7918
    # https://github.com/NixOS/nixpkgs/issues/347248
    # https://wiki.nixos.org/wiki/Fwupd
    # https://github.com/fwupd/fwupd
    services.fwupd = {
      enable = true;
      extraRemotes = ["lvfs-testing"];
    };
  };
}
