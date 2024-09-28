{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.gnome-keyring;
in {
  options.custom.services.gnome-keyring.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/GNOME/Keyring
    # https://gitlab.gnome.org/GNOME/gnome-keyring
    services.gnome.gnome-keyring.enable = true;
    home-manager.users.${config.custom.username}.services.gnome-keyring.enable = true;
  };
}
