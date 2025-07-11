{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.gns3;
in {
  options.custom.programs.gns3 = {
    enable = mkEnableOption "gns3";
  };

  config = mkIf cfg.enable {
    # https://www.gns3.com/
    # https://github.com/GNS3/gns3-gui
    # https://wiki.nixos.org/wiki/GNS3
    # https://wiki.archlinux.org/title/GNS3
    environment.systemPackages = [pkgs.gns3-gui];

    services.gns3-server = {
      enable = true;
      dynamips.enable = true;
    };
  };
}
