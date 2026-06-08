{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.settings;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.desktops.dms.settings = {
    enable = mkEnableOption "settings";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://danklinux.com/docs/dankmaterialshell/nixos-flake#settings-home-manager-only
        programs.dank-material-shell = {
          # https://raw.githubusercontent.com/AvengeMedia/DankMaterialShell/refs/heads/master/quickshell/Common/settings/SettingsSpec.js
          settings = {
            customThemeFile = ./themes/solarized.json; # https://danklinux.com/docs/dankmaterialshell/custom-themes
          };

          # https://raw.githubusercontent.com/AvengeMedia/DankMaterialShell/refs/heads/master/quickshell/Common/settings/SessionSpec.js
          session = {};
        };
      }
    ];
  };
}
