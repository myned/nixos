{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nh;
in {
  options.custom.programs.nh.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/viperML/nh
    programs.nh = {
      enable = true;
      flake = "/etc/nixos";

      clean = {
        enable = true;
        extraArgs = "--keep-since 7d";
      };
    };
  };
}
