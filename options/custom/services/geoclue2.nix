{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.geoclue2;

  where-am-i = "${config.services.geoclue2.package}/libexec/geoclue-2.0/demos/where-am-i";
in {
  options.custom.services.geoclue2 = {
    enable = mkEnableOption "geoclue2";
  };

  config = mkIf cfg.enable {
    # https://gitlab.freedesktop.org/geoclue/geoclue
    # https://man.archlinux.org/man/extra/geoclue/geoclue.5.en
    services.geoclue2.enable = true;

    # https://github.com/maxbrunet/automatic-timezoned
    services.automatic-timezoned.enable = config.time.timeZone == null;

    # HACK: Command not part of package outputs
    #?? where-am-i
    environment.shellAliases = {
      inherit where-am-i;
    };
  };
}
