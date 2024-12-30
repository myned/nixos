{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.openrazer;
in {
  options.custom.services.openrazer = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Hardware/Razer
    hardware.openrazer = {
      enable = true;
      users = [config.custom.username];
    };

    # https://polychromatic.app/
    environment.systemPackages = [pkgs.polychromatic];
  };
}
