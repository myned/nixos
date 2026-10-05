{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms;
in {
  options.custom.desktops.dms = {
    enable = mkEnableOption "dms";
  };

  config = mkIf cfg.enable {
    custom.desktops.dms = {
      greeter.enable = true;
      plugins.enable = true;
      search.enable = true;
      settings.enable = true;
    };

    # https://danklinux.com/
    # https://github.com/AvengeMedia/DankMaterialShell
    programs.dms-shell = {
      enable = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableVPN = true;
      systemd.enable = true;
      systemd.restartIfChanged = true;
    };

    # TODO: Fix stylix colorscheme
    #// stylix.targets.dank-material-shell.enable = true;

    home-manager.sharedModules = [
      {
        # TODO: Use settings module to set
        xdg.configFile."DankMaterialShell/themes" = {
          source = ./themes;
          force = true;
        };
      }
    ];
  };
}
