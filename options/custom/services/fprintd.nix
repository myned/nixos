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
    # https://www.freedesktop.org/wiki/Software/fprint
    # https://wiki.nixos.org/wiki/Fingerprint_scanner
    # https://wiki.archlinux.org/title/Fprint
    #!! Configuration is imperative
    #?? fprintd-enroll -f FINGER
    services.fprintd.enable = true;

    # TODO: Use alternate PAM module when packaged
    # https://github.com/NixOS/nixpkgs/issues/395807
    # https://wiki.nixos.org/wiki/Fingerprint_scanner#Login
    security.pam.services.login.fprintAuth = false;
  };
}
