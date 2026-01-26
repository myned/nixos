{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.displaylink;
in {
  options.custom.services.displaylink = {
    enable = mkEnableOption "displaylink";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Displaylink
    environment.systemPackages = [pkgs.displaylink];
    services.xserver.videoDrivers = ["displaylink"];
    systemd.services.dlm.wantedBy = ["multi-user.target"];
  };
}
