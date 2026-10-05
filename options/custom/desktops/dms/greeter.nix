{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.greeter;
in {
  options.custom.desktops.dms.greeter = {
    enable = mkEnableOption "greeter";
  };

  config = mkIf cfg.enable {
    # https://danklinux.com/docs/dankgreeter/
    services.displayManager.dms-greeter = {
      enable = true;
      compositor.name = config.custom.desktop;
    };
  };
}
