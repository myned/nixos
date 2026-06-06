{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.xwayland-satellite;

  xwayland-satellite = getExe pkgs.xwayland-satellite;
in {
  options.custom.services.xwayland-satellite = {
    enable = mkEnableOption "xwayland-satellite";
  };

  config = mkIf cfg.enable {
    # HACK: Use official module if added
    # BUG: Fractional scaling is currently not supported
    # https://github.com/Supreeeme/xwayland-satellite/issues/11
    # Rootless Xwayland support as a user service
    # https://github.com/Supreeeme/xwayland-satellite
    # https://github.com/Supreeeme/xwayland-satellite/blob/main/resources/xwayland-satellite.service
    systemd.user.services.xwayland-satellite = {
      unitConfig = {
        Description = "Xwayland outside your Wayland";
        BindsTo = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
      };

      serviceConfig = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = xwayland-satellite;
        StandardOutput = "journal";
      };

      wantedBy = ["graphical-session.target"];
    };
  };
}
