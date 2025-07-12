{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nh;
in {
  options.custom.programs.nh = {
    enable = mkEnableOption "nh";

    clean = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/viperML/nh
    programs.nh = {
      enable = true;
      flake = "/etc/nixos";

      clean = {
        enable = cfg.clean;
        extraArgs = "--keep 3 --keep-since 7d";
      };
    };
  };
}
