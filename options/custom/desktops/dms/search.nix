{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.search;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.desktops.dms.search = {
    enable = mkEnableOption "search";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://danklinux.com/docs/danksearch/nixos-flake
        imports = [inputs.danksearch.homeModules.dsearch];

        # https://danklinux.com/docs/danksearch/nixos-flake#basic-configuration
        programs.dsearch = {
          enable = true;
          package = pkgs.dsearch;
        };
      }
    ];
  };
}
