{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.logind;
in {
  options.custom.services.logind.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    services.logind = {
      lidSwitch = "hybrid-sleep"; # Laptop lid switch
    };
  };
}
