{ config, lib, ... }:

with lib;

let
  cfg = config.custom.services.cliphist;
in
{
  options.custom.services.cliphist.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/sentriz/cliphist
    services.cliphist.enable = true;
  };
}
