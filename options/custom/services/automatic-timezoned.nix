{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.automatic-timezoned;
in {
  options.custom.services.automatic-timezoned.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/maxbrunet/automatic-timezoned
    services.automatic-timezoned.enable = true;
  };
}
