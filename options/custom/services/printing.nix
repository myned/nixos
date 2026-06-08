{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.printing;
in {
  options.custom.services.printing = {
    enable = mkEnableOption "printing";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Printing
    services.printing = {
      enable = true;
      webInterface = false; # 631/tcp

      drivers = with pkgs; [
        cups-browsed
        cups-filters
      ];
    };

    environment.systemPackages = [pkgs.system-config-printer];
    users.users.${config.custom.username}.extraGroups = ["lpadmin"];
  };
}
