{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.glances;
in {
  options.custom.services.glances = {
    enable = mkEnableOption "glances";

    server = mkOption {
      default = false;
      description = "Whether to enable the background service";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://nicolargo.github.io/glances/
    # https://github.com/nicolargo/glances
    # https://glances.readthedocs.io/en/latest/index.html
    services.glances = {
      enable = cfg.server;
      port = 61208;

      package = pkgs.glances.overrideAttrs (final: prev: {
        propagatedBuildInputs =
          prev.propagatedBuildInputs
          ++ (with pkgs.python3Packages; [
            batinfo # Battery
            docker
            podman
            pymdstat # RAID
            pysmart # S.M.A.R.T.
          ]);
      });

      # https://glances.readthedocs.io/en/latest/cmds.html
      extraArgs = [
        "--disable-autodiscover"
      ];
    };

    environment = {
      systemPackages = optionals (!cfg.server) [config.services.glances.package];

      # https://glances.readthedocs.io/en/latest/config.html
      etc."glances/glances.conf".text = generators.toINI {} ({
          global = {
            check_update = false;
            left_menu = "network,wifi,connections,ports,diskio,fs,irq,folders,raid,smart,sensors,now";
          };
        }
        // optionalAttrs config.custom.containers.enable {
          # https://glances.readthedocs.io/en/latest/aoa/containers.html
          containers = {
            disable = false;
          };
        }
        // optionalAttrs config.custom.settings.storage.raid.enable {
          # https://glances.readthedocs.io/en/latest/aoa/raid.html
          raid = {
            disable = false;
          };
        }
        // optionalAttrs config.custom.services.smartd.enable {
          # https://glances.readthedocs.io/en/latest/aoa/smart.html
          smart = {
            disable = false;
          };
        }
        // optionalAttrs config.custom.settings.vm.enable {
          # https://glances.readthedocs.io/en/latest/aoa/vms.html
          vms = {
            disable = false;
            all = true;
          };
        });
    };
  };
}
