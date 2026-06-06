{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.mullvad;
in {
  options.custom.services.mullvad = {
    enable = mkEnableOption "mullvad";
  };

  config = mkIf cfg.enable {
    # https://mullvad.net/
    # https://github.com/mullvad/mullvadvpn-app
    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn; # GUI
    };
  };
}
