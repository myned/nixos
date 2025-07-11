{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.kde;
in {
  options.custom.desktops.kde = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
  };
}
