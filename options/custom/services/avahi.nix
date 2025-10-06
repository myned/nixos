{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.avahi;
in {
  options.custom.services.avahi = {
    enable = mkEnableOption "avahi";
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Avahi
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      #// nssmdns6 = true;
      openFirewall = true;
    };
  };
}
