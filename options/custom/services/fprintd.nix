{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.fprintd;
in {
  options.custom.services.fprintd.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Fprint
    # https://www.freedesktop.org/wiki/Software/fprint
    #!! Configuration is imperative
    #?? fprintd-enroll -f FINGER
    services.fprintd.enable = true;
  };
}
