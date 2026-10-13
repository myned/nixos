{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.greeter;
in {
  options.custom.desktops.dms.greeter = {
    enable = mkEnableOption "greeter";

    autoLogin = mkOption {
      description = "Log in automatically at boot";
      default = true;
      example = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services.displayManager =
      {
        # https://danklinux.com/docs/dankgreeter/
        dms-greeter = {
          enable = true;
          compositor.name = config.custom.desktop;
        };
      }
      // optionalAttrs cfg.autoLogin {
        autoLogin = {
          enable = true;
          user = config.custom.username;
        };

        defaultSession = config.custom.desktop;
      };

    security.pam.services.greetd.fprintAuth = false; # Disable fingerprint login
  };
}
