{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.sysprof;
in {
  options.custom.services.sysprof = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://gitlab.gnome.org/GNOME/sysprof
    services.sysprof.enable = true;
  };
}
