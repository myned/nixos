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
          settings = let
            mkOutputs = outputs:
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
              outputs;
          in [
            {
              profile = {
                name = "default";
                outputs = mkOutputs config.custom.display.outputs;
              };
            }

            {
              profile = {
                name = "60Hz";
                outputs = mkOutputs (mapAttrs (
                    _: output:
                      recursiveUpdate output {finalRefresh = 60;}
                  )
                  config.custom.display.outputs);
              };
            }

            {
              profile = {
                name = "16x9";
                outputs = mkOutputs (mapAttrs (
                    _: output:
                      recursiveUpdate output {
                        width = output.height * 16 / 9;
                        finalRefresh = 60;
                      }
                  )
                  config.custom.display.outputs);
              };
            }

            {
              profile = {
                name = "phone";
                outputs = mkOutputs (mapAttrs (
                    _: output:
                      recursiveUpdate output {
                        width = 2076;
                        height = 2152;
                        finalRefresh = 60;
                      }
                  )
                  config.custom.display.outputs);
              };
            }
          ];
        };
      }
    ];
  };
}
