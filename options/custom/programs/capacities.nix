{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.capacities;
in {
  options.custom.programs.capacities = {
    enable = mkEnableOption "capacities";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.capacities];

    home-manager.users.${config.custom.username} = {
      # HACK: Override packaged desktop file to fix Exec=
      #?? cat /run/current-system/sw/share/applications/capacities.desktop
      xdg.desktopEntries.capacities.settings = {
        Name = "Capacities";
        Exec = "${getExe pkgs.capacities} %U";
        Terminal = "false";
        Type = "Application";
        Icon = "capacities";
        StartupWMClass = "Capacities";
        X-AppImage-Version = pkgs.capacities.version;
        Comment = "Capacities";
        MimeType = "x-scheme-handler/capacities";
        Categories = "Education";
      };
    };
  };
}
