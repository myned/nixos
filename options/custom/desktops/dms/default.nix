{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms;
  hm = config.home-manager.users.${config.custom.username};
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

    home-manager.sharedModules = [
      {
        # https://danklinux.com/docs/dankmaterialshell/nixos-flake
        imports = [inputs.dms.homeModules.dank-material-shell];

        # https://danklinux.com/
        # https://github.com/AvengeMedia/DankMaterialShell
        programs.dank-material-shell = {
          enable = true;
          enableAudioWavelength = true;
          enableCalendarEvents = true;
          enableClipboardPaste = true;
          enableDynamicTheming = true;
          enableSystemMonitoring = true;
          enableVPN = true;
          systemd.enable = true;
          systemd.restartIfChanged = true;
          package = pkgs.dms-shell;
          quickshell.package = pkgs.quickshell;
        };

        # TODO: Fix stylix colorscheme
        #// stylix.targets.dank-material-shell.enable = true;

        # TODO: Use settings module to set
        xdg.configFile."DankMaterialShell/themes" = {
          source = ./themes;
          force = true;
        };
      }
    ];
  };
}
