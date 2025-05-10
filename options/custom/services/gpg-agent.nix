{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.gpg-agent;
in {
  options.custom.services.gpg-agent.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/GnuPG#gpg-agent
    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3; # Default: curses
    };
  };
}
