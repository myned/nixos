{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.earlyoom;
in {
  options.custom.services.earlyoom = {
    enable = mkEnableOption "earlyoom";
  };

  config = mkIf cfg.enable {
    # https://github.com/rfjakob/earlyoom
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
    };
  };
}
