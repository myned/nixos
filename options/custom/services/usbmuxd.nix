{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.usbmuxd;
in {
  options.custom.services.usbmuxd.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    services.usbmuxd.enable = true;
    environment.systemPackages = with pkgs; [libimobiledevice];
  };
}
