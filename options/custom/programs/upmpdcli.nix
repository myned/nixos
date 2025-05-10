{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.upmpdcli;
in {
  options.custom.services.upmpdcli = {
    enable = mkEnableOption "upmpdcli";
  };

  config =
    mkIf cfg.enable {
    };
}
