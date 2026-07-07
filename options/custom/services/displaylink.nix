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

    autoStart = mkOption {
      description = "Whether to start the DisplayLink service at login";
      default = false;
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Displaylink
    environment.systemPackages = [pkgs.displaylink];
    services.xserver.videoDrivers = ["displaylink"];
    systemd.services.dlm.wantedBy = mkIf cfg.autoStart ["multi-user.target"];
  };
}
