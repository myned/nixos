{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.seahorse;
in {
  options.custom.programs.seahorse.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    programs.seahorse.enable = true;
  };
}
