{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.gpg;
in {
  options.custom.programs.gpg.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://wiki.archlinux.org/title/GnuPG
        # https://gnupg.org
        programs.gpg = {
          enable = true;
          settings.keyserver = "hkp://keyserver.ubuntu.com";
        };
      }
    ];
  };
}
