{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.qalculate;
in {
  options.custom.programs.qalculate = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/Qalculate/libqalculate
    # https://qalculate.github.io/manual/qalc.html
    environment.systemPackages = [pkgs.libqalculate];

    home-manager.sharedModules = [
      {
        xdg.configFile = {
          # https://github.com/svenstaro/rofi-calc?tab=readme-ov-file#advanced-usage
          "qalculate/qalc.cfg".text = ''
            digit_grouping=2
          '';
        };
      }
    ];
  };
}
