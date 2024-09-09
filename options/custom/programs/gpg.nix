{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.gpg;
in
{
  options.custom.programs.gpg.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/GnuPG
    # https://gnupg.org
    programs.gpg = {
      enable = true;
      settings.keyserver = "hkp://keyserver.ubuntu.com";
    };
  };
}
