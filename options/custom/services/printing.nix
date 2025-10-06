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

      drivers = with pkgs; [
        cups-browsed
        cups-filters
      ];
    };
  };
}
