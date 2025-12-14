{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.display.kanshi;
in {
  options.custom.display.kanshi = {
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
          settings = [
            {
              profile = {
                name = "default";

                outputs =
                  mapAttrsToList (
                    name: output:
                      with output; {
                        criteria = name;
                        adaptiveSync = vrr;
                        scale = scale;

                        status =
                          if enable
                          then "enable"
                          else "disable";

                        mode = "${
                          if force && !config.custom.display.forceAtBoot
                          then "--custom "
                          else ""
                        }${toString width}x${toString height}@${toString finalRefresh}";
                      }
                  )
                  config.custom.display.outputs;
              };
            }

            {
              profile = {
                name = "60";

                outputs =
                  mapAttrsToList (
                    name: output:
                      with output; {
                        criteria = name;
                        adaptiveSync = vrr;
                        scale = scale;

                        status =
                          if enable
                          then "enable"
                          else "disable";

                        mode = "${
                          if force && !config.custom.display.forceAtBoot
                          then "--custom "
                          else ""
                        }${toString width}x${toString height}@60";
                      }
                  )
                  config.custom.display.outputs;
              };
            }
          ];
        };
      }
    ];
  };
}
