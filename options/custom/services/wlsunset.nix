{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.wlsunset;
in {
  options.custom.services.wlsunset = {
    enable = mkEnableOption "wlsunset";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://sr.ht/~kennylevinsen/wlsunset/
      services.wlsunset = {
        enable = true;
        sunrise = "08:00";
        sunset = "20:00";

        temperature = {
          day = 5000;
          night = 4000;
        };
      };
    };
  };
}
