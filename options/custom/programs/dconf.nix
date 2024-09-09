{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.dconf;
in
{
  options.custom.programs.dconf.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://gitlab.gnome.org/GNOME/dconf
    programs.dconf.enable = true;
  };
}
