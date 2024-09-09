{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.nushell;
in
{
  options.custom.programs.nushell.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # TODO: Create config
    # https://github.com/nushell/nushell
    programs.nushell = {
      enable = true;
    };
  };
}
