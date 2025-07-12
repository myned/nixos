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
    package = mkOption {default = mkForce pkgs.kdePackages.kdeconnect-kde;};
  };

  config = mkIf cfg.enable {
    # https://github.com/KDE/kdeconnect-kde
    programs.kdeconnect = {
      enable = true;
      package = cfg.package;
    };

    home-manager.users.${config.custom.username} = {
      services.kdeconnect = {
        enable = true;
        package = cfg.package;
      };
    };
  };
}
