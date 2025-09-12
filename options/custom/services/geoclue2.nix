{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.geoclue2;

  where-am-i = "${config.services.geoclue2.package}/libexec/geoclue-2.0/demos/where-am-i";
in {
  options.custom.services.geoclue2 = {
    enable = mkEnableOption "geoclue2";

    apps = mkOption {
      default = [];
      description = "Desktop ids of apps to allow access to geolocation without authorization";
      example = ["firefox"];
      type = with types; listOf str;
    };

    static = mkOption {
      default = false;
      description = "Whether to use a static source";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://gitlab.freedesktop.org/geoclue/geoclue
    # https://man.archlinux.org/man/extra/geoclue/geoclue.5.en
    services.geoclue2 =
      {
        enable = true;

        # HACK: Set to empty to allow all requests
        # https://gitlab.freedesktop.org/geoclue/geoclue/-/commit/521df77f5bca2eb3ece0048f466b93e28a16e236
        #// whitelistedAgents = [];

        # HACK: Does not entirely work as it relies on the demo agent
        # https://gitlab.freedesktop.org/geoclue/geoclue/-/issues/74
        # https://man.archlinux.org/man/extra/geoclue/geoclue.5.en#APPLICATION_CONFIGURATION_OPTIONS
        appConfig = listToAttrs (forEach cfg.apps (name: {
          inherit name;

          value = {
            isAllowed = true;
            isSystem = mkDefault false;
          };
        }));
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

    environment = {
      # Manually use static source from coordinates
      # https://github.com/NixOS/nixpkgs/issues/311595#issuecomment-2247989491
      etc = mkIf cfg.static {
        "geolocation".source = config.age.secrets."common/geoclue2/geolocation".path;

        "geoclue/conf.d/00-config.conf".text = ''
          [static-source]
          enable=true
        '';
      };

      # FIXME: Desktop file may be required for permissions
      # HACK: Command not part of package outputs
      #?? where-am-i
      shellAliases = {
        inherit where-am-i;
      };
    };

    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = "geoclue";
        group = "geoclue";
      };
    in
      mkIf cfg.static {
        "common/geoclue2/geolocation" = secret "common/geoclue2/geolocation";
      };
  };
}
