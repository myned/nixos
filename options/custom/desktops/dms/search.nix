{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.search;
in {
  options.custom.desktops.dms.search = {
    enable = mkEnableOption "search";
  };

  config = mkIf cfg.enable {
    # https://danklinux.com/docs/danksearch/nixos-flake#basic-configuration
    programs.dsearch = {
      enable = true;
      package = pkgs.dsearch;
    };
  };
}
