{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.envfs;
in {
  options.custom.services.envfs = {
    enable = mkEnableOption "envfs";
  };

  config = mkIf cfg.enable {
    services.envfs.enable = true;
  };
}
