{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.smartd;
in {
  options.custom.services.smartd = {
    enable = mkEnableOption "smartd";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Smartmontools
    environment.systemPackages = [pkgs.smartmontools];

    services.smartd = {
      enable = true;

      notifications = {
        systembus-notify.enable = true;

        # TODO: Set up mailer
        mail = {
        };
      };
    };
  };
}
