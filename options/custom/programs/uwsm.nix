{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.uwsm;
in {
  options.custom.programs.uwsm = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/Vladimir-csp/uwsm
    programs.uwsm.enable = true;
  };
}
