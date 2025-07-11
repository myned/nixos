{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.kanshi;
in {
  options.custom.services.kanshi = {
    enable = mkEnableOption "kanshi";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://wiki.archlinux.org/title/Kanshi
        # https://gitlab.freedesktop.org/emersion/kanshi
        services.kanshi = {
          enable = true;

          # https://gitlab.freedesktop.org/emersion/kanshi/-/blob/master/doc/kanshi.5.scd
          settings = with config.custom; [
            {
              profile = {
                name = "default";

                outputs = [
                  {
                    status = "enable";

                    # BUG: Wildcards do not match
                    # https://gitlab.freedesktop.org/emersion/kanshi/-/issues/54
                    criteria = "\\*";

                    # FIXME: Custom modes do not apply
                    mode = "${toString width}x${toString height}@${toString refresh}";

                    scale = scale;
                    adaptiveSync = vrr;
                  }
                ];
              };
            }
          ];
        };
      }
    ];
  };
}
