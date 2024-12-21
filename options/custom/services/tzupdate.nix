{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.tzupdate;
in {
  options.custom.services.tzupdate.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/cdown/tzupdate
    services.tzupdate.enable = true;
  };
}
