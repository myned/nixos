{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.kdeconnect;
in {
  options.custom.services.kdeconnect = {
    enable = mkOption {default = false;};
    display = mkOption {default = null;};
    package = mkOption {default = mkForce pkgs.kdePackages.kdeconnect-kde;};
  };

  config = mkIf cfg.enable {
    # https://github.com/KDE/kdeconnect-kde
    programs.kdeconnect = {
      enable = true;
      package = cfg.package;
    };

    home-manager.sharedModules = [
      {
        services.kdeconnect = {
          enable = true;
          package = cfg.package;
        };

        # HACK: Manually set DISPLAY variable if specified
        systemd.user.services.kdeconnect = mkIf (!isNull cfg.display) {
          Service = {
            Environment = ["DISPLAY=:${toString cfg.display}"];
          };
        };
      }
    ];
  };
}
