{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.dconf;
in {
  options.custom.settings.dconf.default = mkOption {default = false;};

  config.custom.settings.dconf = mkIf cfg.default {
    apps.enable = true;
    gnome.enable = true;
    gnome-shell.enable = true;
  };
}
