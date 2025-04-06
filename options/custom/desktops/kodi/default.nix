{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.kodi;
in {
  options.custom.desktops.kodi = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    custom = {
      programs.kodi.enable = true;
    };

    services = {
      displayManager.autoLogin = {
        enable = true;
        user = "kodi";
      };

      xserver = {
        enable = true;
        displayManager.lightdm.greeter.enable = false;

        desktopManager.kodi = {
          enable = true;
          package = config.custom.programs.kodi.package;
        };
      };
    };

    users.users.kodi = {
      isNormalUser = true;
    };
  };
}
