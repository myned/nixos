{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.plugins;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.desktops.dms.plugins = {
    enable = mkEnableOption "plugins";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/AvengeMedia/dms-plugin-registry
        imports = [inputs.dms-plugin-registry.homeModules.default];

        # https://danklinux.com/plugins
        # https://danklinux.com/docs/dankmaterialshell/plugins-overview
        programs.dank-material-shell.plugins = {
          # Official
          # https://github.com/AvengeMedia/dms-plugins
          dankBatteryAlerts.enable = true;
          dankClight.enable = true;
          dankKDEConnect.enable = true;
          dankNotepadModule.enable = true;

          # Third-party
          #// activateLinux.enable = true; # https://github.com/hthienloc/dms-activate-linux
          bongoCat.enable = true; # https://github.com/hthienloc/dms-bongo-cat
          calculator.enable = true; # https://github.com/rochacbruno/DankCalculator
          dankDiskUsage.enable = true; # https://github.com/alcxyz/DankDiskUsage
          dankQuickSearch.enable = true; # https://github.com/alcxyz/DankQuickSearch
          dankTranslate.enable = true; # https://github.com/alcxyz/DankTranslate
          #// dankVault.enable = true; # https://github.com/alcxyz/DankVault
          dnsSwitcher.enable = true; # https://github.com/JDKamalakar/DMS-DNS_Switcher
          #// floaty.enable = true; # https://github.com/hthienloc/dms-floaty
          #// homeAssistantMonitor.enable = true; # https://github.com/xxyangyoulin/dms-plugin-hass
          ipIndicator.enable = true; # https://github.com/hthienloc/dms-ipIndicator
          kaomojiPicker.enable = true; # https://github.com/hthienloc/dms-kaomoji-picker
          nixPackageRunner.enable = true; # https://github.com/iahccc/NixPackageRunner
          ocrScanner.enable = true; # https://github.com/hthienloc/dms-ocr-scanner
          powerUsagePlugin.enable = true; # https://github.com/Daniel-42-z/dms-power-usage
          #// quickCapture.enable = true; # https://github.com/hthienloc/dms-quick-capture
          #// screenCaptureToolbar.enable = true; # https://github.com/JDKamalakar/DMS-ScreenCapture_Toolbar
          stopwatch.enable = true; # https://github.com/hthienloc/dms-stopwatch
          tailscale.enable = true; # https://github.com/cglavin50/dms-tailscale
          timer.enable = true; # https://github.com/hthienloc/dms-timer
        };
      }
    ];
  };
}
