{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.geoclue2;
in {
  options.custom.services.geoclue2 = {
    enable = mkOption {default = false;};
    static = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = "geoclue";
        group = "geoclue";
      };
    in {
      "common/geoclue2/geolocation" = mkIf cfg.static (secret "common/geoclue2/geolocation");
    };

    # https://gitlab.freedesktop.org/geoclue/geoclue
    # FIXME: geoclue2 relies on MLS, which is retired
    # https://github.com/NixOS/nixpkgs/issues/321121
    services.geoclue2 =
      {
        enable = true;
      }
      // optionalAttrs cfg.static {
        # TODO: Use static source option when merged into unstable
        # https://github.com/NixOS/nixpkgs/pull/329654
        # Overriden by static source
        enable3G = false;
        enableCDMA = false;
        enableModemGPS = false;
        enableNmea = false;
        enableWifi = false;
      };

    # Manually use static source from coordinates
    # https://github.com/NixOS/nixpkgs/issues/311595#issuecomment-2247989491
    environment.etc = mkIf cfg.static {
      "geolocation".source = config.age.secrets."common/geoclue2/geolocation".path;

      "geoclue/conf.d/00-config.conf".text = ''
        [static-source]
        enable=true
      '';
    };
  };
}
