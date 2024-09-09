{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.wpaperd;
in
{
  options.custom.programs.wpaperd.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/danyspin97/wpaperd
    programs.wpaperd = {
      enable = true;

      settings.default = {
        path = "/tmp/altered.png";
      };
    };
  };
}
